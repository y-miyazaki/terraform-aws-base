#!/bin/bash
#######################################
# Description:
#   Detect unreleased changelog-worthy commits for loop-changelog.
#
# Usage: ./detect_changelog_commits.sh [--scope all|range] [--since <ref>]
#   --scope    Change detection scope (default: range for loop-detect)
#              all: last CHANGELOG_MAX_COMMITS commits on HEAD (local debugging)
#              range: git log <ref>..HEAD (requires --since; production path)
#   --since    Git ref for range scope (commit SHA from loop state)
#
# Output:
# - JSON object with changelog_file, changelog_exists, commit_range, commits[], repository, repository_url, compare_url, skip
#
# Design Rules:
# - Include conventional commits (feat:, fix:, chore:, …)
# - Include other explicit prefixed commits (renovate(scope):, chore(deps):, …)
# - Skip subjects without a clear "prefix: description" shape
# - Output structured JSON via shared lib/json.sh
# - Exit 0 always (errors reported in JSON status field)
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/ai/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - git
#
# Optional environment:
#   CHANGELOG_FILE            Target changelog path (default: CHANGELOG.md)
#   CHANGELOG_MAX_COMMITS     Max commits for --scope all (default: 100)
#   CHANGELOG_MERGE_COMMITS   Include merge commits when "true" (default: false)
#   CHANGELOG_REPOSITORY      owner/repo override (optional)
#   CHANGELOG_REPOSITORY_URL  Repository web base URL override (optional, no trailing slash)
#   GITHUB_SERVER_URL         Used with GITHUB_REPOSITORY in Actions (auto)
#   GITHUB_REPOSITORY         Used with GITHUB_SERVER_URL in Actions (auto)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

#######################################
# Global variables
#######################################
SCOPE="range"
SINCE_REF=""
COMPARE_URL=""
HEAD_SHA=""
COMMIT_RANGE=""
CHANGELOG_EXISTS="false"
CONVENTIONAL_TYPES="feat fix docs style refactor perf test build ci chore revert"

declare -a COMMITS_JSON=()
declare -a RELEASES_JSON=()

#######################################
# show_usage: Display script usage information
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   Exits with code 0
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << 'EOF'
Usage: detect_changelog_commits.sh [--scope all|range] [--since <ref>]

Description:
    Detect unreleased changelog-worthy commits for loop-changelog.

Options:
    --scope    Change detection scope (default: range)
               all: last CHANGELOG_MAX_COMMITS commits on HEAD (debugging)
               range: git log <ref>..HEAD (requires --since)
    --since    Git ref for range scope (commit SHA from loop state)

Examples:
    ./detect_changelog_commits.sh --scope range --since abc1234
    ./detect_changelog_commits.sh --scope all
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Globals:
#   SCOPE - Detection scope
#   SINCE_REF - Git ref for range scope
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   None
#
# Returns:
#   None (calls output_error on invalid input)
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help)
                show_usage
                ;;
            --scope)
                if [[ $# -lt 2 ]]; then
                    output_error "--scope requires a value"
                fi
                SCOPE="$2"
                shift 2
                ;;
            --since)
                if [[ $# -lt 2 ]]; then
                    output_error "--since requires a value"
                fi
                SINCE_REF="$2"
                shift 2
                ;;
            *)
                output_error "Unknown argument: $1"
                ;;
        esac
    done

    if [[ ${SCOPE} != "all" && ${SCOPE} != "range" ]]; then
        output_error "--scope must be all or range"
    fi

    if [[ ${SCOPE} == "range" && -z ${SINCE_REF} ]]; then
        output_error "--scope range requires --since <ref>"
    fi
}

#######################################
# collect_commits: Collect changelog-worthy commits from git log
#
# Description:
#   Resolve the active git range, scan commit subjects, and populate COMMITS_JSON.
#
# Globals:
#   SCOPE - Detection scope
#   SINCE_REF - Range start ref
#   COMMIT_RANGE - Active diff range label
#   CHANGELOG_FILE - Target changelog path
#   CHANGELOG_EXISTS - Whether CHANGELOG_FILE exists
#   CHANGELOG_MERGE_COMMITS - Merge commit inclusion flag
#   COMMITS_JSON - Output array of commit JSON objects
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None (calls output_error on fatal errors)
#
# Usage:
#   collect_commits
#
#######################################
function collect_commits {
    local diff_ref
    local log_args=()
    local sha subject body commit_type scope breaking rest

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        output_error "Not a git repository"
    fi

    detect_changelog_exists

    if [[ ${CHANGELOG_MERGE_COMMITS} != "true" ]]; then
        log_args+=(--no-merges)
    fi

    if [[ ${SCOPE} == "range" ]]; then
        diff_ref="${SINCE_REF}..HEAD"
        COMMIT_RANGE="${diff_ref}"
    else
        diff_ref="HEAD"
        COMMIT_RANGE="HEAD~${CHANGELOG_MAX_COMMITS}..HEAD"
        log_args+=(-n "${CHANGELOG_MAX_COMMITS}")
    fi

    while IFS=$'\t' read -r sha subject body; do
        [[ -z ${sha} ]] && continue
        if ! parse_commit_subject "${subject}" commit_type scope breaking rest; then
            continue
        fi
        if is_loop_maintenance_commit "${commit_type}" "${scope}" "${rest}"; then
            continue
        fi
        if grep -qi 'BREAKING CHANGE' <<< "${body}"; then
            breaking="true"
        fi

        COMMITS_JSON+=("$(commit_object_json "${sha}" "${commit_type}" "${scope}" "${breaking}" "${rest}")")
    done < <(git log "${log_args[@]}" "${diff_ref}" --pretty=format:'%H%x09%s%x09%b%n' 2> /dev/null || true)

    HEAD_SHA="$(git rev-parse HEAD 2> /dev/null || true)"
}

#######################################
# get_repository_from_git: Resolve owner/repo from origin remote URL
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   owner/repo on stdout when detected
#
# Returns:
#   0 on success, 1 otherwise
#
#######################################
function get_repository_from_git {
    local remote_url

    if ! git remote get-url origin &> /dev/null; then
        return 1
    fi

    remote_url="$(git remote get-url origin)"
    if [[ ${remote_url} =~ github\.com[:/]([^/]+)/(.+?)(\.git)?$ ]]; then
        printf '%s/%s' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]%.git}"
        return 0
    fi

    return 1
}

#######################################
# resolve_repository_context: Populate REPOSITORY and REPOSITORY_URL
#
# Description:
#   Prefer CHANGELOG_* overrides, then GitHub Actions env, then git remote.
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function resolve_repository_context {
    local detected_repo=""

    if [[ -n ${REPOSITORY_URL} ]]; then
        REPOSITORY_URL="${REPOSITORY_URL%/}"
        if [[ -z ${REPOSITORY} ]]; then
            if [[ ${REPOSITORY_URL} =~ github\.com/([^/]+/[^/]+)$ ]]; then
                REPOSITORY="${BASH_REMATCH[1]}"
            fi
        fi
        return 0
    fi

    if [[ -n ${GITHUB_SERVER_URL:-} && -n ${GITHUB_REPOSITORY:-} ]]; then
        REPOSITORY="${GITHUB_REPOSITORY}"
        REPOSITORY_URL="${GITHUB_SERVER_URL%/}/${GITHUB_REPOSITORY}"
        return 0
    fi

    if [[ -n ${REPOSITORY} ]]; then
        REPOSITORY_URL="https://github.com/${REPOSITORY}"
        return 0
    fi

    if detected_repo="$(get_repository_from_git)"; then
        REPOSITORY="${detected_repo}"
        REPOSITORY_URL="https://github.com/${REPOSITORY}"
        return 0
    fi

    REPOSITORY=""
    REPOSITORY_URL=""
}

#######################################
# resolve_compare_url: Set COMPARE_URL from repository context and active range
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function resolve_compare_url {
    COMPARE_URL=""

    if [[ -z ${REPOSITORY_URL} || -z ${HEAD_SHA} ]]; then
        return 0
    fi

    if [[ ${SCOPE} == "range" && -n ${SINCE_REF} ]]; then
        COMPARE_URL="${REPOSITORY_URL}/compare/${SINCE_REF}...${HEAD_SHA}"
    fi
}

#######################################
# commit_object_json: Build one commit object as JSON
#
# Globals:
#   None
#
# Arguments:
#   $1 - Commit SHA
#   $2 - Commit type prefix
#   $3 - Optional scope
#   $4 - Breaking flag (true|false)
#   $5 - Subject text after the prefix
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   commit_object_json "${sha}" "${commit_type}" "${scope}" "${breaking}" "${rest}"
#
#######################################
function commit_object_json {
    local sha="$1"
    local commit_type="$2"
    local scope="$3"
    local breaking="$4"
    local subject="$5"

    cat << EOF
{
  "sha": "$(json_escape "${sha}")",
  "type": "$(json_escape "${commit_type}")",
  "scope": "$(json_escape "${scope}")",
  "breaking": ${breaking},
  "subject": "$(json_escape "${subject}")"
}
EOF
}

#######################################
# commits_array_json: Join commit objects into a JSON array string
#
# Globals:
#   COMMITS_JSON - Source commit objects
#
# Arguments:
#   None
#
# Outputs:
#   JSON array string to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   commits_array="$(commits_array_json)"
#
#######################################
function commits_array_json {
    local joined="" commit
    if [[ ${#COMMITS_JSON[@]} -eq 0 ]]; then
        printf '%s' "[]"
        return
    fi
    for commit in "${COMMITS_JSON[@]}"; do
        if [[ -n ${joined} ]]; then
            joined+=","
        fi
        joined+="${commit}"
    done
    printf '[%s]' "${joined}"
}

#######################################
# detect_changelog_exists: Set CHANGELOG_EXISTS from CHANGELOG_FILE
#
# Globals:
#   CHANGELOG_FILE - Path to inspect
#   CHANGELOG_EXISTS - Set to true when the file exists
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   detect_changelog_exists
#
#######################################
function detect_changelog_exists {
    if [[ -f ${CHANGELOG_FILE} ]]; then
        CHANGELOG_EXISTS="true"
    fi
}

#######################################
# is_conventional_type: Check whether a type is a conventional commit prefix
#
# Globals:
#   CONVENTIONAL_TYPES - Allowed conventional type list
#
# Arguments:
#   $1 - Commit type prefix
#
# Outputs:
#   None
#
# Returns:
#   0 if conventional, 1 otherwise
#
# Usage:
#   if is_conventional_type "${commit_type}"; then ...
#
#######################################
function is_conventional_type {
    local commit_type="$1"
    local allowed

    for allowed in ${CONVENTIONAL_TYPES}; do
        [[ ${commit_type} == "${allowed}" ]] && return 0
    done
    return 1
}

#######################################
# is_loop_maintenance_commit: Return 0 for loop-changelog automation commits
#
# Description:
#   Skip commits produced by this loop so they are not re-ingested on the next scan.
#
# Globals:
#   None
#
# Arguments:
#   $1 - Parsed commit type
#   $2 - Parsed commit scope
#   $3 - Subject text after the prefix
#
# Outputs:
#   None
#
# Returns:
#   0 when the commit should be skipped, 1 otherwise
#
# Usage:
#   if is_loop_maintenance_commit "${commit_type}" "${scope}" "${rest}"; then continue; fi
#
#######################################
function is_loop_maintenance_commit {
    local commit_type="$1"
    local scope="$2"
    local subject="$3"

    if [[ ${commit_type} == "chore" && ${scope} == "changelog" ]]; then
        return 0
    fi
    if [[ ${subject} == *"(loop-changelog)"* ]]; then
        return 0
    fi
    return 1
}

#######################################
# output_error: Print structured JSON error and exit
#
# Globals:
#   SCOPE - Detection scope
#   SINCE_REF - Range start ref
#   CHANGELOG_FILE - Target changelog path
#   CHANGELOG_EXISTS - Whether CHANGELOG_FILE exists
#   COMMIT_RANGE - Active diff range label
#
# Arguments:
#   $1 - Error message
#
# Outputs:
#   None
#
# Returns:
#   Exits with code 0
#
# Usage:
#   output_error "Not a git repository"
#
#######################################
function output_error {
    local message="$1"
    json_object_start
    json_field_string "status" "error" ","
    json_field_string "scope" "${SCOPE}" ","
    json_field_string "since" "${SINCE_REF}" ","
    json_field_string "changelog_file" "${CHANGELOG_FILE}" ","
    json_field_bool "changelog_exists" "${CHANGELOG_EXISTS}" ","
    json_field_string "commit_range" "${COMMIT_RANGE}" ","
    json_field_string "repository" "${REPOSITORY}" ","
    json_field_string "repository_url" "${REPOSITORY_URL}" ","
    json_field_string "compare_url" "${COMPARE_URL}" ","
    json_field_bool "skip" "true" ","
    json_field_array "commits" "[]" ","
    json_field_array "releases" "[]" ","
    json_field_string "message" "${message}" ""
    json_object_end
    exit 0
}

#######################################
# output_json: Print structured JSON result using lib/json.sh helpers
#
# Globals:
#   SCOPE - Detection scope
#   SINCE_REF - Range start ref
#   CHANGELOG_FILE - Target changelog path
#   CHANGELOG_EXISTS - Whether CHANGELOG_FILE exists
#   COMMIT_RANGE - Active diff range label
#   COMMITS_JSON - Collected commit objects
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   output_json
#
#######################################
function output_json {
    local skip="false"
    local commits_array
    local releases_array

    if [[ ${#COMMITS_JSON[@]} -eq 0 && ${#RELEASES_JSON[@]} -eq 0 ]]; then
        skip="true"
    fi

    commits_array="$(commits_array_json)"
    releases_array="$(releases_array_json)"
    resolve_repository_context
    resolve_compare_url

    json_object_start
    json_field_string "status" "ok" ","
    json_field_string "scope" "${SCOPE}" ","
    json_field_string "since" "${SINCE_REF}" ","
    json_field_string "changelog_file" "${CHANGELOG_FILE}" ","
    json_field_bool "changelog_exists" "${CHANGELOG_EXISTS}" ","
    json_field_string "commit_range" "${COMMIT_RANGE}" ","
    json_field_string "repository" "${REPOSITORY}" ","
    json_field_string "repository_url" "${REPOSITORY_URL}" ","
    json_field_string "compare_url" "${COMPARE_URL}" ","
    json_field_bool "skip" "${skip}" ","
    json_field_array "commits" "${commits_array}" ","
    json_field_array "releases" "${releases_array}" ""
    json_object_end
}

#######################################
# parse_commit_subject: Parse a changelog-worthy commit subject line
#
# Description:
#   Accept conventional commits and other explicit "prefix(scope): subject" lines.
#
# Globals:
#   CONVENTIONAL_TYPES - Allowed conventional type list
#
# Arguments:
#   $1 - Full commit subject
#   $2 - Nameref for commit type output
#   $3 - Nameref for scope output
#   $4 - Nameref for breaking flag output
#   $5 - Nameref for subject text output
#
# Outputs:
#   None
#
# Returns:
#   0 when parsed, 1 when the subject should be skipped
#
# Usage:
#   parse_commit_subject "${subject}" commit_type scope breaking rest
#
#######################################
function parse_commit_subject {
    local subject="$1"
    # shellcheck disable=SC2034  # nameref output parameters are written by assignment
    local -n out_type="$2"
    local -n out_scope="$3"
    local -n out_breaking="$4"
    local -n out_rest="$5"
    local header

    header="${subject%%: *}"
    out_rest="${subject#*: }"
    [[ -z ${out_rest} || ${out_rest} == "${subject}" ]] && return 1
    [[ ${#out_rest} -lt 3 ]] && return 1

    local breaking_flag="false"
    if [[ ${header} == *'!'* ]]; then
        breaking_flag="true"
        header="${header//'!'/}"
    fi
    # shellcheck disable=SC2034
    out_breaking="${breaking_flag}"

    if [[ ${header} == *"("*")" ]]; then
        out_type="${header%%(*}"
        out_scope="${header#*(}"
        out_scope="${out_scope%%)*}"
    else
        out_type="${header}"
        out_scope=""
    fi

    [[ -z ${out_type} ]] && return 1

    if is_conventional_type "${out_type}"; then
        return 0
    fi

    if [[ ${out_type} =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        return 0
    fi

    return 1
}

#######################################
# version_documented_in_changelog: Return 0 when ## [version] exists
#
# Globals:
#   None
#
# Arguments:
#   $1 - Semantic version without leading v (e.g. 1.8.16)
#
# Outputs:
#   None
#
# Returns:
#   0 when documented, 1 otherwise
#
#######################################
function version_documented_in_changelog {
    local version="$1"

    [[ -f ${CHANGELOG_FILE} ]] || return 1
    grep -qE "^## \\[${version//./\\.}\\]" "${CHANGELOG_FILE}"
}

#######################################
# extract_release_version_from_subject: Parse semver from pin/finalize subjects
#
# Globals:
#   None
#
# Arguments:
#   $1 - Commit subject text after prefix
#
# Outputs:
#   version on stdout when matched
#
# Returns:
#   0 on success, 1 otherwise
#
#######################################
function extract_release_version_from_subject {
    local subject="$1"

    if [[ ! ${subject} =~ [Pp]in|[Ff]inalize|[Aa]lign ]]; then
        return 1
    fi
    if [[ ${subject} =~ v?([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        printf '%s' "${BASH_REMATCH[1]}"
        return 0
    fi
    return 1
}

#######################################
# release_object_json: Build one release object as JSON
#
# Globals:
#   None
#
# Arguments:
#   $1 - Version without leading v
#   $2 - Tag name (e.g. v1.8.16)
#   $3 - Tag or anchor commit SHA
#   $4 - Release date (YYYY-MM-DD)
#   $5 - JSON array string of commit SHAs
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   0 on success
#
#######################################
function release_object_json {
    local version="$1"
    local tag="$2"
    local tag_sha="$3"
    local release_date="$4"
    local commit_shas="$5"

    cat << EOF
{
  "version": "$(json_escape "${version}")",
  "tag": "$(json_escape "${tag}")",
  "tag_sha": "$(json_escape "${tag_sha}")",
  "date": "$(json_escape "${release_date}")",
  "commit_shas": ${commit_shas}
}
EOF
}

#######################################
# releases_array_json: Join release objects into a JSON array string
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   JSON array string to stdout
#
# Returns:
#   0 on success
#
#######################################
function releases_array_json {
    local joined="" release
    if [[ ${#RELEASES_JSON[@]} -eq 0 ]]; then
        printf '%s' "[]"
        return
    fi
    for release in "${RELEASES_JSON[@]}"; do
        if [[ -n ${joined} ]]; then
            joined+=","
        fi
        joined+="${release}"
    done
    printf '[%s]' "${joined}"
}

#######################################
# commit_in_tag_release_range: Return 0 when a commit belongs to a tag release range
#
# Globals:
#   SCOPE - Detection scope
#   SINCE_REF - Range start ref for range scope
#
# Arguments:
#   $1 - Commit SHA
#   $2 - Tag anchor commit SHA
#
# Outputs:
#   None
#
# Returns:
#   0 when the commit is in the release range, 1 otherwise
#
#######################################
function commit_in_tag_release_range {
    local sha="$1"
    local tag_sha="$2"

    git merge-base --is-ancestor "${sha}" "${tag_sha}" 2> /dev/null || return 1
    if [[ ${SCOPE} == "range" && -n ${SINCE_REF} ]]; then
        git merge-base --is-ancestor "${SINCE_REF}" "${sha}" 2> /dev/null || return 1
        [[ "$(git rev-parse "${SINCE_REF}")" == "${sha}" ]] && return 1
    fi
    return 0
}

#######################################
# release_commit_shas_json: Build commit_shas JSON array for one release version
#
# Globals:
#   COMMITS_JSON - Collected commits
#
# Arguments:
#   $1 - Version without leading v
#   $2 - Tag anchor commit SHA
#   $3 - Optional comma-separated quoted pin-commit SHA list
#
# Outputs:
#   JSON array string to stdout
#
# Returns:
#   0 on success
#
#######################################
function release_commit_shas_json {
    local version="$1"
    local tag_sha="$2"
    local pin_commit_list="${3:-}"
    local -A seen=()
    local -a sha_list=()
    local commit_json sha entry

    if [[ -n ${pin_commit_list} ]]; then
        while IFS= read -r entry; do
            [[ -z ${entry} ]] && continue
            sha="${entry//\"/}"
            [[ -n ${seen["${sha}"]+x} ]] && continue
            seen["${sha}"]=1
            sha_list+=("\"${sha}\"")
        done < <(printf '%s' "${pin_commit_list}" | tr ',' '\n')
    fi

    for commit_json in "${COMMITS_JSON[@]}"; do
        sha="$(jq -r '.sha' <<< "${commit_json}")"
        [[ -n ${seen["${sha}"]+x} ]] && continue
        if commit_in_tag_release_range "${sha}" "${tag_sha}"; then
            seen["${sha}"]=1
            sha_list+=("\"${sha}\"")
        fi
    done

    if [[ ${#sha_list[@]} -eq 0 ]]; then
        printf '[%s]' "\"${tag_sha}\""
        return 0
    fi

    local joined=""
    for sha in "${sha_list[@]}"; do
        if [[ -n ${joined} ]]; then
            joined+=","
        fi
        joined+="${sha}"
    done
    printf '[%s]' "${joined}"
}

#######################################
# collect_releases: Build RELEASES_JSON from tags and undocumented versions
#
# Globals:
#   CHANGELOG_FILE - Target changelog path
#   COMMITS_JSON - Collected commits (used for pin grouping)
#   RELEASES_JSON - Output release objects
#   SINCE_REF - Range start ref
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function collect_releases {
    local -A version_tags=()
    local -A version_dates=()
    local -A version_tag_shas=()
    local -A version_commit_lists=()
    local tag tag_sha release_date version commit_json sha subject commit_shas

    detect_changelog_exists

    while IFS= read -r tag; do
        [[ -z ${tag} ]] && continue
        [[ ${tag} =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || continue
        version="${tag#v}"
        version_documented_in_changelog "${version}" && continue
        tag_sha="$(git rev-parse "${tag}^{commit}" 2> /dev/null || true)"
        [[ -z ${tag_sha} ]] && continue
        if [[ ${SCOPE} == "range" ]]; then
            if ! git merge-base --is-ancestor "${SINCE_REF}" "${tag_sha}" 2> /dev/null; then
                continue
            fi
            if git merge-base --is-ancestor "${tag_sha}" "${SINCE_REF}" 2> /dev/null \
                && [[ "$(git rev-parse "${SINCE_REF}")" == "${tag_sha}" ]]; then
                continue
            fi
        fi
        release_date="$(git log -1 --format=%aI "${tag_sha}" 2> /dev/null | cut -dT -f1)"
        version_tags["${version}"]="${tag}"
        version_tag_shas["${version}"]="${tag_sha}"
        version_dates["${version}"]="${release_date}"
    done < <(git tag -l 'v[0-9]*.[0-9]*.[0-9]*' --sort=-creatordate 2> /dev/null || true)

    for commit_json in "${COMMITS_JSON[@]}"; do
        sha="$(jq -r '.sha' <<< "${commit_json}")"
        subject="$(jq -r '.subject' <<< "${commit_json}")"
        version="$(extract_release_version_from_subject "${subject}" || true)"
        [[ -z ${version} ]] && continue
        version_documented_in_changelog "${version}" && continue
        if [[ -z ${version_commit_lists["${version}"]+x} ]]; then
            version_commit_lists["${version}"]="\"${sha}\""
        else
            version_commit_lists["${version}"]+=",\"${sha}\""
        fi
        if [[ -z ${version_dates["${version}"]+x} ]]; then
            version_dates["${version}"]="$(git log -1 --format=%aI "${sha}" 2> /dev/null | cut -dT -f1)"
        fi
        if [[ -z ${version_tags["${version}"]+x} ]]; then
            version_tags["${version}"]="v${version}"
            version_tag_shas["${version}"]="${sha}"
        fi
    done

    for version in "${!version_tags[@]}"; do
        commit_shas="$(release_commit_shas_json \
            "${version}" \
            "${version_tag_shas["${version}"]}" \
            "${version_commit_lists["${version}"]:-}")"
        RELEASES_JSON+=("$(release_object_json \
            "${version}" \
            "${version_tags["${version}"]}" \
            "${version_tag_shas["${version}"]}" \
            "${version_dates["${version}"]}" \
            "${commit_shas}")")
    done
}

#######################################
# configure_detect_environment: Normalize domain env into globals once at startup
#
# Globals:
#   CHANGELOG_FILE - Target changelog path
#   CHANGELOG_MAX_COMMITS - Max commits for --scope all
#   CHANGELOG_MERGE_COMMITS - Include merge commits when "true"
#   REPOSITORY - owner/repo override
#   REPOSITORY_URL - Repository web base URL override
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   configure_detect_environment
#
#######################################
function configure_detect_environment {
    CHANGELOG_FILE="${CHANGELOG_FILE:-CHANGELOG.md}"
    CHANGELOG_FILE="${CHANGELOG_FILE#./}"
    CHANGELOG_MAX_COMMITS="${CHANGELOG_MAX_COMMITS:-100}"
    CHANGELOG_MERGE_COMMITS="${CHANGELOG_MERGE_COMMITS:-false}"
    REPOSITORY="${CHANGELOG_REPOSITORY:-}"
    REPOSITORY_URL="${CHANGELOG_REPOSITORY_URL:-}"
}

#######################################
# main: Entry point
#
# Globals:
#   None
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   None
#
# Returns:
#   0 always
#
# Usage:
#   main "$@"
#
#######################################
function main {
    configure_detect_environment
    parse_arguments "$@"
    collect_commits
    collect_releases
    output_json
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
