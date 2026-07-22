#!/bin/bash
#######################################
# Description: Sensor functions for detect_report_tech_debt.sh
#
# Usage: sourced by detect_report_tech_debt.sh (not executed directly)
#
# Design Rules:
# - Depends on globals and lib/all.sh loaded by the parent script
# - Emit facts into SIGNALS_JSON, HOTSPOTS_JSON, and WARNINGS
#######################################

MARKER_PER_FILE_CAP=10
MARKER_GLOBAL_CAP=50
DEP_PER_FILE_CAP=20
DEP_GLOBAL_CAP=50
MLC_VERSION="3.14.2"

declare -a SIGNALS_JSON=()
declare -a HOTSPOTS_JSON=()
declare -a WARNINGS=()
declare -A MARKER_FILE_COUNTS=()
MARKER_GLOBAL_COUNT=0
MARKER_TRUNCATED=false
declare -A DEP_FILE_COUNTS=()
DEP_GLOBAL_COUNT=0
DEP_TRUNCATED=false

#######################################
# signal_object_json: Function implementation
#
# Globals:
#   None
#
# Arguments:
#   $1-$6 - kind, path, line, snippet, source, hint (hint optional)
#
# Outputs:
#   JSON object on stdout
#
# Returns:
#   0 on success
#
#######################################
function signal_object_json {
    local kind="$1"
    local path="$2"
    local line="$3"
    local snippet="$4"
    local source="$5"
    local hint="${6:-}"

    if [[ -n ${hint} ]]; then
        cat << EOF
{
  "kind": "$(json_escape "${kind}")",
  "path": "$(json_escape "${path}")",
  "line": ${line},
  "snippet": "$(json_escape "${snippet}")",
  "source": "$(json_escape "${source}")",
  "hint": "$(json_escape "${hint}")"
}
EOF
    else
        cat << EOF
{
  "kind": "$(json_escape "${kind}")",
  "path": "$(json_escape "${path}")",
  "line": ${line},
  "snippet": "$(json_escape "${snippet}")",
  "source": "$(json_escape "${source}")"
}
EOF
    fi
}

#######################################
# append_dependency_signal: Append one dependency signal when dep caps allow
#
# Globals:
#   SIGNALS_JSON - Output array of signal objects
#   DEP_FILE_COUNTS - Per-file dependency signal counts
#   DEP_GLOBAL_COUNT - Total dependency signals collected
#   DEP_TRUNCATED - Set true when a dep cap is reached
#   DEP_PER_FILE_CAP - Maximum dependency signals per manifest file
#   DEP_GLOBAL_CAP - Maximum dependency signals across the repository
#
# Arguments:
#   $1-$6 - kind, path, line, snippet, source, hint (hint optional)
#
# Outputs:
#   None
#
# Returns:
#   0 when appended; 1 when skipped due to caps
#
# Usage:
#   append_dependency_signal "eol_hint" "go.mod" "5" "require x v1" "go_mod" "dependency_version"
#
#######################################
function append_dependency_signal {
    local kind="$1"
    local path="$2"
    local line="$3"
    local snippet="$4"
    local source="$5"
    local hint="${6:-}"
    local file_count

    if [[ ${DEP_GLOBAL_COUNT} -ge ${DEP_GLOBAL_CAP} ]]; then
        DEP_TRUNCATED=true
        return 1
    fi

    file_count="${DEP_FILE_COUNTS[${path}]:-0}"
    if [[ ${file_count} -ge ${DEP_PER_FILE_CAP} ]]; then
        DEP_TRUNCATED=true
        return 1
    fi

    DEP_FILE_COUNTS[${path}]=$((file_count + 1))
    DEP_GLOBAL_COUNT=$((DEP_GLOBAL_COUNT + 1))
    SIGNALS_JSON+=("$(signal_object_json "${kind}" "${path}" "${line}" "${snippet}" "${source}" "${hint}")")
}

#######################################
# append_hotspot: Append one hotspot object to HOTSPOTS_JSON
#
# Globals:
#   HOTSPOTS_JSON - Output array of hotspot objects
#
# Arguments:
#   $1-$4 - path, metric, value, window
#
# Outputs:
#   None
#
# Returns:
#   0 always
#
# Usage:
#   append_hotspot "src/hot.go" "churn" "12" "90d"
#
#######################################
function append_hotspot {
    local path="$1"
    local metric="$2"
    local value="$3"
    local window="$4"

    HOTSPOTS_JSON+=("$(hotspot_object_json "${path}" "${metric}" "${value}" "${window}")")
}

#######################################
# append_signal: Append one marker signal object when marker caps allow
#
# Globals:
#   SIGNALS_JSON - Output array of signal objects
#   MARKER_FILE_COUNTS - Per-file marker counts
#   MARKER_GLOBAL_COUNT - Total marker signals collected
#   MARKER_TRUNCATED - Set true when a cap is reached
#   MARKER_PER_FILE_CAP - Maximum markers per file
#   MARKER_GLOBAL_CAP - Maximum markers across the repository
#
# Arguments:
#   $1-$6 - kind, path, line, snippet, source, hint (hint optional)
#
# Outputs:
#   None
#
# Returns:
#   0 when appended; 1 when skipped due to caps
#
# Usage:
#   append_signal "todo_comment" "src/main.go" "2" "// TODO: x" "git_grep" "code_quality"
#
#######################################
function append_signal {
    local kind="$1"
    local path="$2"
    local line="$3"
    local snippet="$4"
    local source="$5"
    local hint="${6:-}"
    local file_count

    if [[ ${MARKER_GLOBAL_COUNT} -ge ${MARKER_GLOBAL_CAP} ]]; then
        MARKER_TRUNCATED=true
        return 1
    fi

    file_count="${MARKER_FILE_COUNTS[${path}]:-0}"
    if [[ ${file_count} -ge ${MARKER_PER_FILE_CAP} ]]; then
        MARKER_TRUNCATED=true
        return 1
    fi

    MARKER_FILE_COUNTS[${path}]=$((file_count + 1))
    MARKER_GLOBAL_COUNT=$((MARKER_GLOBAL_COUNT + 1))
    SIGNALS_JSON+=("$(signal_object_json "${kind}" "${path}" "${line}" "${snippet}" "${source}" "${hint}")")
}

#######################################
# collect_churn_hotspots: Rank repository paths by recent git commit frequency
#
# Globals:
#   HOTSPOTS_JSON - Output array of hotspot objects
#   TECH_DEBT_CHURN_WINDOW - Churn window (default: 90d)
#   TECH_DEBT_CHURN_MIN - Minimum commit count (default: 5)
#   TECH_DEBT_CHURN_TOP - Top N paths to emit (default: 20)
#   WARNINGS - Warning messages when git log fails
#
# Arguments:
#   $1-$4 - path, metric, value, window
#
# Outputs:
#   JSON array string on stdout
#
# Returns:
#   None
#
# Usage:
#   collect_churn_hotspots
#
#######################################
function collect_churn_hotspots {
    local window="${TECH_DEBT_CHURN_WINDOW:-90d}"
    local min_count="${TECH_DEBT_CHURN_MIN:-5}"
    local top_n="${TECH_DEBT_CHURN_TOP:-20}"
    local emitted=0
    local count path
    local log_output

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 0
    fi

    if ! log_output="$(git log --since="${window}" --name-only --pretty=format: 2> /dev/null)"; then
        WARNINGS+=("churn sensor skipped: git log failed")
        return
    fi

    if [[ -z ${log_output} ]]; then
        return
    fi

    while read -r count path; do
        [[ -z ${path} ]] && continue
        if repo_path_should_skip "${path}"; then
            continue
        fi
        if [[ ${count} -lt ${min_count} ]]; then
            break
        fi
        append_hotspot "${path}" "churn" "${count}" "${window}"
        emitted=$((emitted + 1))
        if [[ ${emitted} -ge ${top_n} ]]; then
            break
        fi
    done < <(
        printf '%s\n' "${log_output}" \
            | grep -v '^[[:space:]]*$' \
            | sort \
            | uniq -c \
            | sort -rn
    )
}

#######################################
# collect_dependency_signals: Scan manifests for dependency version facts
#
# Globals:
#   SIGNALS_JSON - Output array of signal objects
#   WARNINGS - Warning messages
#   DEP_FILE_COUNTS - Per-file dependency signal counts (reset per run)
#   DEP_GLOBAL_COUNT - Total dependency signals collected (reset per run)
#   DEP_TRUNCATED - Truncation flag (reset per run)
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
#   collect_dependency_signals
#
#######################################
function collect_dependency_signals {
    local file

    DEP_FILE_COUNTS=()
    DEP_GLOBAL_COUNT=0
    DEP_TRUNCATED=false

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 0
    fi

    while IFS= read -r file; do
        [[ -z ${file} ]] && continue
        case "${file}" in
            go.mod | */go.mod)
                dependency_signals_from_go_mod "${file}"
                ;;
            package.json | */package.json)
                dependency_signals_from_package_json "${file}"
                ;;
        esac
    done < <(repo_emit_tracked_paths '(^|/)go\.mod$|(^|/)package\.json$')

    if [[ ${DEP_TRUNCATED} == "true" ]]; then
        WARNINGS+=("dependency signals truncated")
    fi
}

#######################################
# collect_doc_signals: Scan markdown for broken links and staleness
#
# Globals:
#   SIGNALS_JSON - Output array of signal objects
#   WARNINGS - Warning messages
#   MLC_VERSION - Pinned markdown-link-check version
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
#   collect_doc_signals
#
#######################################
function collect_doc_signals {
    local stale_days="${TECH_DEBT_STALE_DAYS:-365}"
    local mlc_cli="" file

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 0
    fi

    if ensure_markdown_link_check mlc_cli; then
        while IFS= read -r file; do
            [[ -z ${file} ]] && continue
            doc_broken_links_from_mlc "${mlc_cli}" "${file}" || true
        done < <(repo_emit_tracked_paths '\.md$')
    fi

    while IFS= read -r file; do
        [[ -z ${file} ]] && continue
        doc_maybe_emit_stale_signal "${file}" "${stale_days}" || true
    done < <(repo_emit_tracked_paths '\.md$')
}

#######################################
# collect_marker_signals: Scan tracked files for TODO/FIXME/HACK/XXX markers
#
# Globals:
#   SIGNALS_JSON - Output array of signal objects
#   WARNINGS - Warning messages
#   MARKER_FILE_COUNTS - Per-file marker counts (reset per run)
#   MARKER_GLOBAL_COUNT - Total marker signals collected (reset per run)
#   MARKER_TRUNCATED - Truncation flag (reset per run)
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
#   collect_marker_signals
#
#######################################
function collect_marker_signals {
    local marker_pattern='//[[:space:]]*(TODO|FIXME|HACK|XXX)\b|#[[:space:]]*(TODO|FIXME|HACK|XXX)\b|/\*[[:space:]]*(TODO|HACK|FIXME|XXX)\b|\b(TODO|FIXME|HACK|XXX):'
    local grep_line file rest line content kind

    MARKER_FILE_COUNTS=()
    MARKER_GLOBAL_COUNT=0
    MARKER_TRUNCATED=false

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 0
    fi

    while IFS= read -r grep_line; do
        [[ -z ${grep_line} ]] && continue
        if [[ ${MARKER_GLOBAL_COUNT} -ge ${MARKER_GLOBAL_CAP} ]]; then
            MARKER_TRUNCATED=true
            break
        fi

        file="${grep_line%%:*}"
        rest="${grep_line#*:}"
        line="${rest%%:*}"
        content="${rest#*:}"

        if repo_path_should_skip "${file}"; then
            continue
        fi

        kind="$(marker_kind_from_line "${content}")"
        [[ -z ${kind} ]] && continue

        append_signal "${kind}" "${file}" "${line}" "${content}" "git_grep" "code_quality" || true
    done < <(git grep -nI -E "${marker_pattern}" 2> /dev/null || true)

    if [[ ${MARKER_TRUNCATED} == "true" ]]; then
        WARNINGS+=("marker signals truncated")
    fi
}

#######################################
# dependency_eol_module_listed: Return whether a module is in TECH_DEBT_EOL_MODULES
#
# Globals:
#   None
#
# Arguments:
#   $1 - Module path or package name
#
# Outputs:
#   None
#
# Returns:
#   0 when listed; 1 otherwise
#
# Usage:
#   dependency_eol_module_listed "github.com/old/lib"
#
#######################################
function dependency_eol_module_listed {
    local module="$1"
    local entry trimmed

    [[ -n ${TECH_DEBT_EOL_MODULES:-} ]] || return 1

    IFS=',' read -ra eol_entries <<< "${TECH_DEBT_EOL_MODULES}"
    for entry in "${eol_entries[@]}"; do
        trimmed="${entry#"${entry%%[![:space:]]*}"}"
        trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
        [[ -z ${trimmed} ]] && continue
        if [[ ${module} == "${trimmed}" ]]; then
            return 0
        fi
    done
    return 1
}

#######################################
# dependency_is_version_range: Return whether a version string is a loose range
#
# Globals:
#   None
#
# Arguments:
#   $1 - Version string from a manifest
#
# Outputs:
#   None
#
# Returns:
#   0 when the version uses a range prefix; 1 otherwise
#
# Usage:
#   dependency_is_version_range "^1.0.0"
#
#######################################
function dependency_is_version_range {
    local version="$1"

    case "${version}" in
        ^* | ~* | \** | x* | X*)
            return 0
            ;;
    esac
    return 1
}

#######################################
# dependency_signals_from_go_mod: Emit eol_hint signals from a go.mod file
#
# Globals:
#   SIGNALS_JSON - Output array of signal objects
#
# Arguments:
#   $1 - Repository-relative path to go.mod
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   dependency_signals_from_go_mod "go.mod"
#
#######################################
function dependency_signals_from_go_mod {
    local path="$1"
    local line line_content module version snippet line_num in_require=false
    local -a go_mod_lines=()

    [[ -f ${path} ]] || return 0
    [[ -n ${TECH_DEBT_EOL_MODULES:-} ]] || return 0

    mapfile -t go_mod_lines < "${path}"
    for line_num in "${!go_mod_lines[@]}"; do
        line_content="${go_mod_lines[${line_num}]}"
        line="${line_content%%#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z ${line} ]] && continue

        if [[ ${line} == "require (" ]]; then
            in_require=true
            continue
        fi
        if [[ ${in_require} == "true" && ${line} == ")" ]]; then
            in_require=false
            continue
        fi

        module=""
        version=""
        if [[ ${line} =~ ^require[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
            module="${BASH_REMATCH[1]}"
            version="${BASH_REMATCH[2]}"
        elif [[ ${in_require} == "true" && ${line} =~ ^([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
            module="${BASH_REMATCH[1]}"
            version="${BASH_REMATCH[2]}"
        else
            continue
        fi

        if ! dependency_eol_module_listed "${module}"; then
            continue
        fi

        snippet="require ${module} ${version}"
        append_dependency_signal "eol_hint" "${path}" "$((line_num + 1))" "${snippet}" "go_mod" "dependency_version" || true
    done
}

#######################################
# dependency_signals_from_package_json: Emit npm dependency version signals
#
# Globals:
#   SIGNALS_JSON - Output array of signal objects
#   WARNINGS - Warning messages
#
# Arguments:
#   $1 - Repository-relative path to package.json
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   dependency_signals_from_package_json "package.json"
#
#######################################
function dependency_signals_from_package_json {
    local path="$1"
    local dir lock_path name version snippet resolved line_num
    local line_content current_line

    [[ -f ${path} ]] || return 0

    if ! command -v jq > /dev/null 2>&1; then
        WARNINGS+=("dependency sensor skipped for package.json: jq not available")
        return 0
    fi

    dir="$(dirname "${path}")"
    if [[ ${dir} == "." ]]; then
        lock_path="package-lock.json"
    else
        lock_path="${dir}/package-lock.json"
    fi

    declare -A dep_lines=()
    current_line=0
    while IFS= read -r line_content || [[ -n ${line_content} ]]; do
        current_line=$((current_line + 1))
        if [[ ${line_content} =~ \"([^\"]+)\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
            dep_lines["${BASH_REMATCH[1]}"]="${current_line}"
        fi
    done < "${path}"

    while IFS=$'\t' read -r name version; do
        [[ -z ${name} ]] && continue

        line_num="${dep_lines[${name}]:-1}"
        snippet="\"${name}\": \"${version}\""

        if dependency_is_version_range "${version}"; then
            append_dependency_signal "version_range" "${path}" "${line_num}" "${snippet}" "package_json" "dependency_version" || true
            continue
        fi

        if [[ ! -f ${lock_path} ]]; then
            continue
        fi

        resolved="$(jq -r --arg pkg "${name}" '
            .packages["node_modules/" + $pkg].version //
            .dependencies[$pkg].version //
            empty
        ' "${lock_path}" 2> /dev/null || true)"
        if [[ -n ${resolved} && ${version} != "${resolved}" ]]; then
            snippet="\"${name}\": \"${version}\" (lock: ${resolved})"
            append_dependency_signal "pin_drift" "${path}" "${line_num}" "${snippet}" "package_json" "dependency_version" || true
        fi
    done < <(jq -r '
        (.dependencies // {}), (.devDependencies // {}) | to_entries[] | [.key, .value] | @tsv
    ' "${path}" 2> /dev/null || true)
}

#######################################
# doc_age_days_git: Return days since the last git commit touching a file
#
# Globals:
#   None
#
# Arguments:
#   $1 - Repository-relative file path
#
# Outputs:
#   Age in whole days on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   age="$(doc_age_days_git "docs/guide.md")"
#
#######################################
function doc_age_days_git {
    local file="$1"
    local ts now age

    ts="$(git log -1 --format=%ct -- "${file}" 2> /dev/null || true)"
    if [[ -z ${ts} ]]; then
        printf '0'
        return 0
    fi

    now="$(date +%s)"
    age=$(((now - ts) / 86400))
    printf '%s' "${age}"
}

#######################################
# doc_age_days_mtime: Return days since file mtime
#
# Globals:
#   None
#
# Arguments:
#   $1 - Repository-relative file path
#
# Outputs:
#   Age in whole days on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   age="$(doc_age_days_mtime "docs/guide.md")"
#
#######################################
function doc_age_days_mtime {
    local file="$1"
    local ts now age

    [[ -f ${file} ]] || {
        printf '0'
        return 0
    }

    if stat --version > /dev/null 2>&1; then
        ts="$(stat -c %Y "${file}" 2> /dev/null || printf '0')"
    else
        ts="$(stat -f %m "${file}" 2> /dev/null || printf '0')"
    fi

    now="$(date +%s)"
    age=$(((now - ts) / 86400))
    printf '%s' "${age}"
}

#######################################
# doc_broken_links_from_mlc: Emit broken_doc_ref signals for one markdown file
#
# Globals:
#   SIGNALS_JSON - Output array of signal objects
#   WARNINGS - Warning messages appended on recoverable mlc/jq failures
#
# Arguments:
#   $1 - Path to markdown-link-check CLI from ensure_markdown_link_check
#        (cache install prefix is derived as three parents above .bin/)
#   $2 - Repository-relative markdown file path
#
# Outputs:
#   None
#
# Returns:
#   0 always
#
# Usage:
#   doc_broken_links_from_mlc "${mlc_cli}" "docs/index.md"
#
#######################################
function doc_broken_links_from_mlc {
    local mlc_cli="$1"
    local file="$2"
    local mlc_cache json_output link line_num snippet status_code

    mlc_cache="$(dirname "$(dirname "$(dirname "${mlc_cli}")")")"

    if ! json_output="$(NODE_PATH="${mlc_cache}/node_modules" node -e "
const fs = require('fs');
const path = require('path');
const mlc = require('markdown-link-check');
const file = process.argv[1];
const resolved = path.resolve(file);
const baseUrl = process.platform === 'win32'
    ? 'file://' + path.dirname(resolved).replace(/\\\\/g, '/')
    : 'file://' + path.dirname(resolved);
const md = fs.readFileSync(file, 'utf8');
mlc(md, { baseUrl }, (err, results) => {
    if (err) process.exit(2);
    const dead = (results || []).filter((result) => result.status === 'dead');
    process.stdout.write(JSON.stringify(dead));
});
" "${file}" 2> /dev/null)"; then
        doc_warn_once "docs link sensor skipped: markdown-link-check run failed"
        return 0
    fi

    [[ -n ${json_output} && ${json_output} != "[]" ]] || return 0

    if ! command -v jq > /dev/null 2>&1; then
        doc_warn_once "docs link sensor skipped: jq not available"
        return 0
    fi

    while IFS=$'\t' read -r link status_code; do
        [[ -z ${link} ]] && continue
        line_num="$(doc_line_for_link "${file}" "${link}")"
        snippet="dead link: ${link} (${status_code})"
        SIGNALS_JSON+=("$(signal_object_json "broken_doc_ref" "${file}" "${line_num}" "${snippet}" "markdown_link_check" "documentation")")
    done < <(jq -r '.[] | [.link, (.statusCode | tostring)] | @tsv' <<< "${json_output}" 2> /dev/null || true)
}

#######################################
# doc_line_for_link: Find the first line number containing a link target
#
# Globals:
#   None
#
# Arguments:
#   $1 - Repository-relative markdown file path
#   $2 - Link URL or path to locate
#
# Outputs:
#   1-based line number on stdout (defaults to 1)
#
# Returns:
#   0 on success
#
# Usage:
#   line="$(doc_line_for_link "docs/index.md" "./nope.md")"
#
#######################################
function doc_line_for_link {
    local file="$1"
    local link="$2"
    local line_num=1
    local line_content

    [[ -f ${file} ]] || {
        printf '1'
        return 0
    }

    while IFS= read -r line_content || [[ -n ${line_content} ]]; do
        if [[ ${line_content} == *"${link}"* ]]; then
            printf '%s' "${line_num}"
            return 0
        fi
        line_num=$((line_num + 1))
    done < "${file}"

    printf '1'
}

#######################################
# doc_maybe_emit_stale_signal: Emit stale_doc when age meets threshold
#
# Globals:
#   SIGNALS_JSON - Output array of signal objects
#
# Arguments:
#   $1 - Repository-relative markdown file path
#   $2 - Staleness threshold in days
#
# Outputs:
#   None
#
# Returns:
#   0 always
#
# Usage:
#   doc_maybe_emit_stale_signal "docs/old.md" "365"
#
#######################################
function doc_maybe_emit_stale_signal {
    local file="$1"
    local stale_days="$2"
    local git_age mtime_age snippet source

    git_age="$(doc_age_days_git "${file}")"
    mtime_age="$(doc_age_days_mtime "${file}")"

    if [[ ${git_age} -ge ${stale_days} ]]; then
        snippet="last updated ${git_age}d ago (git)"
        source="git_log"
    elif [[ ${mtime_age} -ge ${stale_days} ]]; then
        snippet="last modified ${mtime_age}d ago (mtime)"
        source="mtime"
    else
        return 0
    fi

    SIGNALS_JSON+=("$(signal_object_json "stale_doc" "${file}" "1" "${snippet}" "${source}" "documentation")")
}

#######################################
# doc_warn_once: Append a docs-sensor warning when not already present
#
# Globals:
#   WARNINGS - Warning messages
#
# Arguments:
#   $1 - Warning message
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   doc_warn_once "docs link sensor skipped: jq not available"
#
#######################################
function doc_warn_once {
    local message="$1"
    local existing

    for existing in "${WARNINGS[@]}"; do
        if [[ ${existing} == "${message}" ]]; then
            return 0
        fi
    done

    WARNINGS+=("${message}")
}

#######################################
# ensure_markdown_link_check: Install or locate pinned markdown-link-check
#
# Globals:
#   WARNINGS - Warning messages appended on recoverable failure
#   MLC_VERSION - Pinned markdown-link-check version
#
# Arguments:
#   None
#
# Outputs:
#   0 when CLI path is written to the output variable; 1 when skipped
#
# Returns:
#   0 on success
#
# Usage:
#   ensure_markdown_link_check mlc_cli
#
#######################################
function ensure_markdown_link_check {
    local -n out_path="${1:?output variable name required}"
    local cache_dir candidate_cli

    out_path=""

    if [[ ${TECH_DEBT_SKIP_MLC:-} == "true" ]]; then
        WARNINGS+=("docs link sensor skipped: TECH_DEBT_SKIP_MLC is set")
        return 1
    fi

    if ! command -v node > /dev/null 2>&1 || ! node -e "process.exit(0)" > /dev/null 2>&1; then
        WARNINGS+=("docs link sensor skipped: node not available")
        return 1
    fi

    if ! command -v npm > /dev/null 2>&1 || ! npm --version > /dev/null 2>&1; then
        WARNINGS+=("docs link sensor skipped: npm not available")
        return 1
    fi

    cache_dir="${TMPDIR:-/tmp}/loop-report-tech-debt-mlc/${MLC_VERSION}"
    candidate_cli="${cache_dir}/node_modules/.bin/markdown-link-check"

    if [[ ! -x ${candidate_cli} ]]; then
        if ! npm install --prefix "${cache_dir}" "markdown-link-check@${MLC_VERSION}" > /dev/null 2>&1; then
            WARNINGS+=("docs link sensor skipped: markdown-link-check install failed")
            return 1
        fi
        candidate_cli="${cache_dir}/node_modules/.bin/markdown-link-check"
        if [[ ! -x ${candidate_cli} ]]; then
            WARNINGS+=("docs link sensor skipped: markdown-link-check binary missing after install")
            return 1
        fi
    fi

    # shellcheck disable=SC2034 # out_path is a nameref; assignment writes caller output
    out_path="${candidate_cli}"
    return 0
}

#######################################
# hotspot_object_json: Build one hotspot object as JSON
#
# Globals:
#   None
#
# Arguments:
#   $1-$4 - path, metric, value, window
#
# Outputs:
#   JSON object on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   hotspot_object_json "pkg/foo.go" "churn" "12" "90d"
#
#######################################
function hotspot_object_json {
    local path="$1"
    local metric="$2"
    local value="$3"
    local window="$4"

    cat << EOF
{
  "path": "$(json_escape "${path}")",
  "metric": "$(json_escape "${metric}")",
  "value": ${value},
  "window": "$(json_escape "${window}")"
}
EOF
}

#######################################
# hotspots_array_json: Join hotspot objects into a JSON array string
#
# Globals:
#   HOTSPOTS_JSON - Source hotspot objects
#
# Arguments:
#   None
#
# Outputs:
#   JSON array string on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   hotspots_array="$(hotspots_array_json)"
#
#######################################
function hotspots_array_json {
    local joined=""
    local hotspot

    if [[ ${#HOTSPOTS_JSON[@]} -eq 0 ]]; then
        printf '%s' "[]"
        return
    fi

    for hotspot in "${HOTSPOTS_JSON[@]}"; do
        if [[ -n ${joined} ]]; then
            joined+=","
        fi
        joined+="${hotspot}"
    done
    printf '[%s]' "${joined}"
}

#######################################
# marker_kind_from_line: Map a matched line to a closed marker kind
#
# Globals:
#   None
#
# Arguments:
#   $1 - Line content from git grep
#
# Outputs:
#   Marker kind on stdout, or empty when no marker is recognized
#
# Returns:
#   0 on success
#
# Usage:
#   kind="$(marker_kind_from_line "${content}")"
#
#######################################
function marker_kind_from_line {
    local line="$1"

    if [[ ${line} =~ (^|[^A-Za-z])TODO([^A-Za-z]|$|:) ]]; then
        printf 'todo_comment'
    elif [[ ${line} =~ (^|[^A-Za-z])FIXME([^A-Za-z]|$|:) ]]; then
        printf 'fixme'
    elif [[ ${line} =~ (^|[^A-Za-z])HACK([^A-Za-z]|$|:) ]]; then
        printf 'hack'
    elif [[ ${line} =~ (^|[^A-Za-z])XXX([^A-Za-z]|$|:) ]]; then
        printf 'xxx'
    fi
}
