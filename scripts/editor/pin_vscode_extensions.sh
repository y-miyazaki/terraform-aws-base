#!/bin/bash
#######################################
# Description:
#   Update pinned VS Code extension versions ("publisher.name@x.y.z") in
#   devcontainer.json files to the latest stable release from the Visual Studio Marketplace
#   (VS Code) or Open VSX (Cursor).
#
# Usage:
#   bash scripts/editor/pin_vscode_extensions.sh [--dry-run] [--min-age-days N] [--registry marketplace|openvsx] [--vscode-version X.Y.Z] [FILE...]
#
# Design Rules:
#   - Only uncommented array entries of the form "publisher.name@version" are read and rewritten;
#     "// ..." lines and unpinned entries stay unchanged
#   - --registry picks the registry and the default FILE: marketplace (default) updates the VS Code example,
#     openvsx updates the Cursor example; the two registries publish different versions, so never mix pins
#   - marketplace: one extensionquery POST covers every pinned ID
#   - openvsx: one versions request per ID, then one detail request per candidate among the newest
#     OPENVSX_CANDIDATES versions (the detail holds the publish date and the pre-release flag)
#   - Pre-release versions are skipped; with --vscode-version (marketplace only), versions whose
#     engines.vscode minimum is newer than that VS Code version are skipped too
#   - Versions published less than --min-age-days ago (default 7, matching Renovate
#     minimumReleaseAge) are skipped; versions without a publish date are skipped too
#   - A pin is never downgraded: a pin newer than every allowed version stays unchanged
#   - Marketplace only: do not run on Open VSX pins (env/example/.devcontainer/cursor/devcontainer.json)
#   - Lookup failures leave the pin unchanged and make the script exit 1 after all other updates
#
# Output:
#   One line per pinned extension on stdout ("FILE: ID OLD -> NEW", "FILE: ID OLD (up to date)",
#   or "FILE: ID OLD (newer than latest allowed NEW; unchanged)")
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

#######################################
# Global variables
#######################################
# Default target, relative to the repository root
DEFAULT_FILE_MARKETPLACE="env/example/.devcontainer/vscode/devcontainer.json"
DEFAULT_FILE_OPENVSX="env/example/.devcontainer/cursor/devcontainer.json"
DRY_RUN=false
FILES=()
# Overridable for tests; the public Marketplace endpoint needs no credentials
MARKETPLACE_URL="${MARKETPLACE_URL:-https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery}"
# Number of newest Open VSX versions inspected per extension (the detail request per version is the cost)
OPENVSX_CANDIDATES=20
# Overridable for tests; the public Open VSX API needs no credentials
OPENVSX_URL="${OPENVSX_URL:-https://open-vsx.org/api}"
# Registry to read versions from: marketplace or openvsx
REGISTRY="marketplace"
# Minimum days since a version was published before it is adopted (0 disables the filter)
MIN_AGE_DAYS=7
# Current time in epoch seconds; overridable for tests
NOW_EPOCH="${NOW_EPOCH:-$(date +%s)}"
# VS Code version (X.Y.Z) used to filter engines.vscode; empty disables the filter
VSCODE_VERSION=""

#######################################
# show_usage: Display script usage
#
# Description:
#   Prints usage information and exits successfully.
#
# Globals:
#   DEFAULT_FILE_MARKETPLACE - Default marketplace target shown in the help text
#   DEFAULT_FILE_OPENVSX     - Default openvsx target shown in the help text
#
# Arguments:
#   None
#
# Outputs:
#   Usage text to stdout
#
# Returns:
#   Exits 0
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [--dry-run] [--min-age-days N] [--registry marketplace|openvsx] [--vscode-version X.Y.Z] [FILE...]

Update pinned VS Code extensions ("publisher.name@x.y.z") in devcontainer.json
to the latest stable version of the Visual Studio Marketplace or Open VSX.

Arguments:
  FILE                    devcontainer.json to update
                          (default: ${DEFAULT_FILE_MARKETPLACE} for marketplace,
                          ${DEFAULT_FILE_OPENVSX} for openvsx)

Options:
  -h, --help              Display this help message
  --dry-run               Report updates without rewriting files
  --min-age-days N        Skip versions published less than N days ago (default: ${MIN_AGE_DAYS}; 0 disables)
  --registry NAME         marketplace (VS Code, default) or openvsx (Cursor)
  --vscode-version X.Y.Z  Skip versions whose engines.vscode needs a newer VS Code (marketplace only)

Examples:
  bash scripts/editor/pin_vscode_extensions.sh --dry-run
  bash scripts/editor/pin_vscode_extensions.sh --registry openvsx
  bash scripts/editor/pin_vscode_extensions.sh --vscode-version 1.106.0
  bash scripts/editor/pin_vscode_extensions.sh --min-age-days 0
  bash scripts/editor/pin_vscode_extensions.sh .devcontainer/devcontainer.json
EOF
    exit 0
}

#######################################
# parse_arguments: Parse CLI options
#
# Description:
#   Supports --dry-run, --min-age-days, --registry, --vscode-version, --help, and positional FILE arguments.
#
# Globals:
#   DRY_RUN        - Set to true when --dry-run is passed
#   FILES          - Appended with positional arguments
#   MIN_AGE_DAYS   - Set from --min-age-days
#   REGISTRY       - Set from --registry
#   VSCODE_VERSION - Set from --vscode-version
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   Error messages to stderr
#
# Returns:
#   Exits 1 on unknown options, an invalid --min-age-days, --registry, or --vscode-version,
#   or --vscode-version combined with --registry openvsx
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help)
                show_usage
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --min-age-days)
                if [[ $# -lt 2 || ! $2 =~ ^[0-9]+$ ]]; then
                    echo "--min-age-days needs a non-negative integer" >&2
                    exit 1
                fi
                MIN_AGE_DAYS="$2"
                shift 2
                ;;
            --registry)
                if [[ $# -lt 2 || ! $2 =~ ^(marketplace|openvsx)$ ]]; then
                    echo "--registry needs marketplace or openvsx" >&2
                    exit 1
                fi
                REGISTRY="$2"
                shift 2
                ;;
            --vscode-version)
                if [[ $# -lt 2 || ! $2 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    echo "--vscode-version needs X.Y.Z" >&2
                    exit 1
                fi
                VSCODE_VERSION="$2"
                shift 2
                ;;
            -*)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
            *)
                FILES+=("$1")
                shift
                ;;
        esac
    done
    if [[ ${REGISTRY} == "openvsx" && -n ${VSCODE_VERSION} ]]; then
        echo "--vscode-version applies to --registry marketplace only" >&2
        exit 1
    fi
}

#######################################
# engine_allows: Check an engines.vscode range against a VS Code version
#
# Description:
#   Reads the minimum version from ranges such as "^1.90.0", ">=1.60.0", or "*"
#   and compares it with the given VS Code version. Upper bounds are not evaluated.
#
# Globals:
#   None
#
# Arguments:
#   $1 - engines.vscode value (may be empty)
#   $2 - VS Code version X.Y.Z (empty allows everything)
#
# Outputs:
#   None
#
# Returns:
#   0 when the version is allowed; 1 otherwise
#
#######################################
function engine_allows {
    local engine="$1"
    local vscode="$2"
    local minimum

    [[ -n ${vscode} ]] || return 0
    minimum="$(sed -E 's/^[[:space:]]*[\^~>=]*[[:space:]]*//; s/-.*$//' <<< "${engine}")"
    [[ ${minimum} =~ ^[0-9]+(\.[0-9]+)*$ ]] || return 0
    [[ "$(printf '%s\n%s\n' "${minimum}" "${vscode}" | sort -V | head -1)" == "${minimum}" ]]
}

#######################################
# extract_pins: List pinned extension entries in a file
#
# Description:
#   Prints uncommented array entries that look like "publisher.name@version".
#
# Globals:
#   None
#
# Arguments:
#   $1 - devcontainer.json path
#
# Outputs:
#   "publisher.name@version" lines on stdout
#
# Returns:
#   0 always
#
#######################################
function extract_pins {
    local file="$1"

    { grep -E '^[[:space:]]*"[A-Za-z0-9-]+\.[A-Za-z0-9._-]+@[A-Za-z0-9.+_-]+"[[:space:]]*,?[[:space:]]*(//.*)?$' "${file}" || true; } \
        | sed -E 's/^[[:space:]]*"([^"]+)".*$/\1/'
}

#######################################
# latest_version: Pick the newest allowed version from a Marketplace response
#
# Description:
#   Matches the extension ID case-insensitively, drops pre-release versions, versions
#   published within MIN_AGE_DAYS (or without a publish date), and versions rejected by
#   engine_allows, and prints the highest remaining version.
#
# Globals:
#   MIN_AGE_DAYS   - Minimum age in days of an adopted version
#   NOW_EPOCH      - Current time in epoch seconds
#   VSCODE_VERSION - Passed to engine_allows
#
# Arguments:
#   $1 - Marketplace response JSON file
#   $2 - Extension ID (publisher.name)
#
# Outputs:
#   Version on stdout
#
# Returns:
#   0 on success; 1 when the extension or an allowed version is not found
#
#######################################
function latest_version {
    local response="$1"
    local id="$2"
    local version prerelease engine old_enough
    local -a candidates=()

    # \x1f separates fields: tab is IFS whitespace, so read would merge an empty engine field
    while IFS=$'\x1f' read -r version prerelease engine old_enough; do
        [[ ${prerelease} == "true" ]] && continue
        [[ ${old_enough} == "true" ]] || continue
        engine_allows "${engine}" "${VSCODE_VERSION}" || continue
        [[ ${version} =~ ^[A-Za-z0-9.+_-]+$ ]] || continue
        candidates+=("${version}")
    done < <(jq -r --arg id "${id,,}" --argjson cutoff "$((NOW_EPOCH - MIN_AGE_DAYS * 86400))" '
        .results[0].extensions[]?
        | select(((.publisher.publisherName + "." + .extensionName) | ascii_downcase) == $id)
        | .versions[]?
        | (reduce (.properties // [])[] as $p ({}; .[$p.key] = $p.value)) as $props
        | [.version,
           ($props["Microsoft.VisualStudio.Code.PreRelease"] // "false"),
           ($props["Microsoft.VisualStudio.Code.Engine"] // ""),
           ((.lastUpdated // "" | sub("\\.[0-9]+"; "") | try fromdateiso8601 catch null) as $t
            | if $t == null then "false" else ($t <= $cutoff | tostring) end)]
        | join("\u001f")' "${response}")

    [[ ${#candidates[@]} -gt 0 ]] || return 1
    printf '%s\n' "${candidates[@]}" | sort -uV | tail -1
}

#######################################
# openvsx_latest_version: Pick the newest allowed version from Open VSX
#
# Description:
#   Lists the newest OPENVSX_CANDIDATES versions of the extension, reads the detail of each,
#   drops pre-release versions and versions published within MIN_AGE_DAYS (or without a publish
#   date), and prints the highest remaining version. The engines.vscode range is not evaluated:
#   Cursor's VS Code base version differs from the one in --vscode-version.
#
# Globals:
#   MIN_AGE_DAYS      - Minimum age in days of an adopted version
#   NOW_EPOCH         - Current time in epoch seconds
#   OPENVSX_CANDIDATES - Number of newest versions inspected
#   OPENVSX_URL       - Open VSX API base URL
#
# Arguments:
#   $1 - Extension ID (publisher.name)
#
# Outputs:
#   Version on stdout
#
# Returns:
#   0 on success; 1 when the request fails or no allowed version is found
#
#######################################
function openvsx_latest_version {
    local id="$1"
    local namespace="${id%%.*}"
    local name="${id#*.}"
    local version old_enough
    local -a candidates=() versions=()

    mapfile -t versions < <(curl -fsS --max-time 60 "${OPENVSX_URL}/${namespace}/${name}/versions?size=${OPENVSX_CANDIDATES}" \
        | jq -r '.versions // {} | keys_unsorted[]')

    for version in "${versions[@]}"; do
        [[ ${version} =~ ^[A-Za-z0-9.+_-]+$ ]] || continue
        old_enough="$(curl -fsS --max-time 60 "${OPENVSX_URL}/${namespace}/${name}/${version}" \
            | jq -r --argjson cutoff "$((NOW_EPOCH - MIN_AGE_DAYS * 86400))" '
                if .preRelease == true then "false"
                else ((.timestamp // "" | sub("\\.[0-9]+"; "") | try fromdateiso8601 catch null) as $t
                    | if $t == null then "false" else ($t <= $cutoff | tostring) end)
                end')" || continue
        [[ ${old_enough} == "true" ]] && candidates+=("${version}")
    done

    [[ ${#candidates[@]} -gt 0 ]] || return 1
    printf '%s\n' "${candidates[@]}" | sort -uV | tail -1
}

#######################################
# query_marketplace: Fetch version data for extension IDs
#
# Description:
#   Sends one extensionquery POST (IncludeVersions | IncludeVersionProperties).
#
# Globals:
#   MARKETPLACE_URL - extensionquery endpoint
#
# Arguments:
#   $1  - Output JSON file
#   $2+ - Extension IDs (publisher.name)
#
# Outputs:
#   Response JSON written to $1
#
# Returns:
#   Non-zero when the request fails
#
#######################################
function query_marketplace {
    local out="$1"
    shift

    jq -n '{filters: [{criteria: [$ARGS.positional[] | {filterType: 7, value: .}], pageSize: 1000}], flags: 17}' \
        --args "$@" \
        | curl -fsS --max-time 60 -X POST "${MARKETPLACE_URL}" \
            -H 'Accept: application/json;api-version=3.0-preview.1' \
            -H 'Content-Type: application/json' \
            --data-binary @- -o "${out}"
}

#######################################
# rewrite_pin: Replace one pinned version in a file
#
# Description:
#   Rewrites "ID@OLD" to "ID@NEW" on uncommented array entry lines only.
#
# Globals:
#   None
#
# Arguments:
#   $1 - File path
#   $2 - Extension ID as written in the file
#   $3 - Current version
#   $4 - New version
#
# Outputs:
#   None
#
# Returns:
#   Non-zero when perl fails
#
#######################################
function rewrite_pin {
    ID="$2" OLD="$3" NEW="$4" perl -pi -e \
        's/^(\s*")\Q$ENV{ID}\E\@\Q$ENV{OLD}\E"/$1$ENV{ID}\@$ENV{NEW}"/' "$1"
}

#######################################
# main: Update pinned extensions in every target file
#
# Description:
#   Collects pins, looks up the latest versions in the selected registry, prints each
#   result, and rewrites files unless --dry-run is set.
#
# Globals:
#   DEFAULT_FILE_MARKETPLACE - Used when no FILE is given and the registry is marketplace
#   DEFAULT_FILE_OPENVSX     - Used when no FILE is given and the registry is openvsx
#   DRY_RUN                  - Skips rewriting when true
#   FILES                    - Target files
#   REGISTRY                 - Registry to read versions from
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   Results to stdout; errors to stderr
#
# Returns:
#   Exits 1 on missing commands, unreadable files, a failed query, or any unresolved pin
#
#######################################
function main {
    local cmd file pin id old new key repo_root response label
    local failed=0
    local -a ids=()
    local -A latest=()
    local -A seen=()

    parse_arguments "$@"
    label="Marketplace"
    [[ ${REGISTRY} == "openvsx" ]] && label="Open VSX"

    for cmd in curl jq perl; do
        if ! command -v "${cmd}" > /dev/null 2>&1; then
            echo "Required command not found: ${cmd}" >&2
            exit 1
        fi
    done

    if [[ ${#FILES[@]} -eq 0 ]]; then
        repo_root="$(git rev-parse --show-toplevel 2> /dev/null || pwd)"
        if [[ ${REGISTRY} == "openvsx" ]]; then
            FILES=("${repo_root}/${DEFAULT_FILE_OPENVSX}")
        else
            FILES=("${repo_root}/${DEFAULT_FILE_MARKETPLACE}")
        fi
    fi
    for file in "${FILES[@]}"; do
        if [[ ! -f ${file} ]]; then
            echo "File not found: ${file}" >&2
            exit 1
        fi
        while IFS= read -r pin; do
            id="${pin%@*}"
            [[ -n ${seen[${id,,}]:-} ]] && continue
            seen[${id,,}]=1
            ids+=("${id}")
        done < <(extract_pins "${file}")
    done

    if [[ ${#ids[@]} -eq 0 ]]; then
        echo "No pinned extensions found"
        return 0
    fi

    if [[ ${REGISTRY} == "openvsx" ]]; then
        for id in "${ids[@]}"; do
            latest[${id,,}]="$(openvsx_latest_version "${id}" || true)"
        done
    else
        response="$(mktemp)"
        # shellcheck disable=SC2064 # expand now: response is local to main
        trap "rm -f '${response}'" EXIT
        if ! query_marketplace "${response}" "${ids[@]}"; then
            echo "Marketplace query failed: ${MARKETPLACE_URL}" >&2
            exit 1
        fi

        for id in "${ids[@]}"; do
            key="${id,,}"
            latest[${key}]="$(latest_version "${response}" "${id}" || true)"
        done
    fi

    for file in "${FILES[@]}"; do
        while IFS= read -r pin; do
            id="${pin%@*}"
            old="${pin##*@}"
            new="${latest[${id,,}]}"
            if [[ -z ${new} ]]; then
                echo "${file}: ${id} ${old} (no stable ${label} version found; unchanged)" >&2
                failed=1
            elif [[ ${new} == "${old}" ]]; then
                echo "${file}: ${id} ${old} (up to date)"
            elif [[ "$(printf '%s\n%s\n' "${old}" "${new}" | sort -V | tail -1)" == "${old}" ]]; then
                echo "${file}: ${id} ${old} (newer than latest allowed ${new}; unchanged)"
            else
                echo "${file}: ${id} ${old} -> ${new}"
                [[ ${DRY_RUN} == true ]] || rewrite_pin "${file}" "${id}" "${old}" "${new}"
            fi
        done < <(extract_pins "${file}")
    done

    return "${failed}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
