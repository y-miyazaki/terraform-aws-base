#!/bin/bash
#######################################
# Description: Repository path filtering for detect scripts and scanners
#
# Usage: source via scripts/lib/all.sh
#
# Output:
# - None (library file, sourced by other scripts)
#
# Design Rules:
# - Enumerate with git or find; filter with repo_path_should_skip / repo_filter_paths
# - Caller-specific exclusions use REPO_PATHS_EXTRA_PRUNES (comma-separated roots)
# - REPO_PATHS_INCLUDE_AGENTS=true skips agent-directory exclusion (default: exclude)
# - REPO_PATHS_INCLUDE_GITIGNORED=true skips gitignore exclusion (default: exclude)
# - Dot-prefixed directory segments are excluded except structural roots (.github, .apm)
# - Root dotfiles are not excluded by the dot-directory rule
# - repo_append_find_prune_args is a performance prune; repo_filter_paths is authoritative
# - Agent directory exclusion aligns with agent-skills.instructions.md S-06 plus .vscode (editor-local)
#######################################

declare -A REPO_PATHS_GITIGNORE_CACHE=()

#######################################
# repo_apply_git_rename: Classify a git rename for detect delta consumers
#
# When both paths are scannable, record renamed_files only. Cross-zone renames also
# append the scannable side to deleted_files or changed_files when git diff filters
# omit it, and always record old->new in renamed_files for downstream rename logic.
#
# Globals:
#   None
#
# Arguments:
#   $1 - Old repository-relative path
#   $2 - New repository-relative path
#   $3 - Name reference to renamed_files array (old->new strings)
#   $4 - Name reference to deleted_files array
#   $5 - Name reference to changed_files array
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   repo_apply_git_rename "${old}" "${new}" RENAMED_FILES DELETED_FILES CHANGED_FILES
#
#######################################
function repo_apply_git_rename {
    local old="$1"
    local new="$2"
    # shellcheck disable=SC2178 # nameref to caller arrays by name
    local -n _renamed=$3
    # shellcheck disable=SC2178 # nameref to caller arrays by name
    local -n _deleted=$4
    # shellcheck disable=SC2178 # nameref to caller arrays by name
    local -n _changed=$5
    local old_scannable=false new_scannable=false

    old="${old#./}"
    new="${new#./}"

    if ! repo_path_should_skip "${old}"; then
        old_scannable=true
    fi
    if ! repo_path_should_skip "${new}"; then
        new_scannable=true
    fi

    if [[ ${old_scannable} == false && ${new_scannable} == false ]]; then
        return 0
    fi

    if [[ ${old_scannable} == true && ${new_scannable} == true ]]; then
        _renamed+=("${old}->${new}")
        return 0
    fi

    _renamed+=("${old}->${new}")
    if [[ ${old_scannable} == true ]]; then
        repo_array_append_unique _deleted "${old}"
    fi
    if [[ ${new_scannable} == true ]]; then
        repo_array_append_unique _changed "${new}"
    fi
}

#######################################
# repo_array_append_unique: Append a path to an array when absent
#
# Globals:
#   None
#
# Arguments:
#   $1 - Name reference to output array
#   $2 - Repository-relative path to append
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   repo_array_append_unique CHANGED_FILES "docs/new.md"
#
#######################################
function repo_array_append_unique {
    # shellcheck disable=SC2178 # nameref to caller array by name
    local -n _out=$1
    local path="$2"
    local existing

    path="${path#./}"
    for existing in "${_out[@]}"; do
        [[ ${existing} == "${path}" ]] && return 0
    done
    _out+=("${path}")
}

#######################################
# repo_append_find_prune_args: Append standard find prune predicates to an array
#
# Globals:
#   REPO_PATHS_EXTRA_PRUNES - Comma-separated repository-relative prune roots
#   REPO_PATHS_INCLUDE_AGENTS - When true, do not prune agent directories
#
# Arguments:
#   $1 - Name reference to find argument array
#   $@ - Optional extra repository-relative prune roots (merged with REPO_PATHS_EXTRA_PRUNES)
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   local -a find_args=(.)
#   repo_append_find_prune_args find_args
#   find_args+=(-name '*.md' -type f -print)
#   find "${find_args[@]}" | sed 's|^\./||' | repo_filter_paths
#
#######################################
function repo_append_find_prune_args {
    # shellcheck disable=SC2178 # nameref to caller array by name
    local -n _out=$1
    shift
    local -a extra_prunes=()
    local extra

    mapfile -t extra_prunes < <(repo_list_extra_prune_roots "$@")

    _out+=(\( -path './.git')
    if [[ ${REPO_PATHS_INCLUDE_AGENTS:-false} != "true" ]]; then
        _out+=(-o -path './.agents' -o -path './.cursor' -o -path './.claude' -o -path './.codex' -o -path './.kiro' -o -path './.vscode')
    fi
    _out+=(-o -path './apm_modules' -o -path './node_modules' -o -path './dist' -o -path './build' -o -path './bin')
    for extra in "${extra_prunes[@]}"; do
        [[ -z ${extra} ]] && continue
        extra="${extra#./}"
        _out+=(-o -path "./${extra}" -o -path "./${extra}/*")
    done
    _out+=(\) -prune -o)
}

#######################################
# repo_emit_tracked_paths: Emit filtered tracked repository paths
#
# Globals:
#   REPO_PATHS_EXTRA_PRUNES - Comma-separated repository-relative prune roots
#   REPO_PATHS_INCLUDE_AGENTS - When true, do not exclude agent directories
#   REPO_PATHS_INCLUDE_GITIGNORED - When true, do not exclude gitignored paths
#
# Arguments:
#   $1 - Optional extended-regex path filter (empty = all tracked paths)
#
# Outputs:
#   Filtered repository-relative paths on stdout (one per line)
#
# Returns:
#   0 on success
#
# Usage:
#   repo_emit_tracked_paths '\.md$'
#
#######################################
function repo_emit_tracked_paths {
    local pattern="${1:-}"
    local file

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 0
    fi

    while IFS= read -r file; do
        [[ -z ${file} ]] && continue
        if [[ -n ${pattern} ]] && [[ ! ${file} =~ ${pattern} ]]; then
            continue
        fi
        if repo_path_should_skip "${file}"; then
            continue
        fi
        printf '%s\n' "${file}"
    done < <(git ls-files 2> /dev/null || true)
}

#######################################
# repo_filter_paths: Emit stdin paths that should be scanned
#
# Globals:
#   REPO_PATHS_EXTRA_PRUNES - Comma-separated repository-relative prune roots
#   REPO_PATHS_INCLUDE_AGENTS - When true, do not exclude agent directories
#   REPO_PATHS_INCLUDE_GITIGNORED - When true, do not exclude gitignored paths
#
# Arguments:
#   None
#
# Outputs:
#   Filtered repository-relative paths on stdout (one per line)
#
# Returns:
#   0 on success
#
# Usage:
#   git diff --name-only | repo_filter_paths
#
#######################################
function repo_filter_paths {
    local path

    while IFS= read -r path; do
        [[ -z ${path} ]] && continue
        path="${path#./}"
        if repo_path_should_skip "${path}"; then
            continue
        fi
        printf '%s\n' "${path}"
    done
}

#######################################
# repo_list_extra_prune_roots: Emit merged env and call-time prune roots
#
# Globals:
#   REPO_PATHS_EXTRA_PRUNES - Comma-separated repository-relative prune roots
#
# Arguments:
#   $@ - Optional extra repository-relative prune roots
#
# Outputs:
#   Repository-relative prune roots on stdout (one per line)
#
# Returns:
#   0 on success
#
# Usage:
#   mapfile -t extras < <(repo_list_extra_prune_roots "docs/report")
#
#######################################
function repo_list_extra_prune_roots {
    local -a call_extras=("$@")
    local csv item trimmed extra

    csv="${REPO_PATHS_EXTRA_PRUNES:-}"
    if [[ -n ${csv} ]]; then
        while IFS= read -r item || [[ -n ${item} ]]; do
            trimmed="${item#"${item%%[![:space:]]*}"}"
            trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
            [[ -z ${trimmed} ]] && continue
            trimmed="${trimmed#./}"
            printf '%s\n' "${trimmed}"
        done < <(printf '%s' "${csv}" | tr ',' '\n')
    fi
    for extra in "${call_extras[@]}"; do
        [[ -z ${extra} ]] && continue
        extra="${extra#./}"
        printf '%s\n' "${extra}"
    done
}

#######################################
# repo_path_has_excluded_dot_directory: Return whether a path has a non-scannable dot directory
#
# Dot-prefixed segments are directories when more path remains; the final
# segment (filename) is never excluded by this rule. Structural scannable
# dot directories are .github and .apm only.
#
# Globals:
#   REPO_PATHS_INCLUDE_AGENTS - When true, agent directory segments are scannable
#
# Arguments:
#   $1 - Repository-relative file path
#
# Outputs:
#   None
#
# Returns:
#   0 when a non-scannable dot directory is present; 1 otherwise
#
# Usage:
#   repo_path_has_excluded_dot_directory ".env/common/local.env"
#
#######################################
function repo_path_has_excluded_dot_directory {
    local path="$1"
    local part
    local -a parts=()
    local -i count idx

    path="${path#./}"
    IFS='/' read -ra parts <<< "${path}"
    count=${#parts[@]}

    for ((idx = 0; idx < count; idx++)); do
        part="${parts[idx]}"
        [[ ${part} != .* ]] && continue

        if ((idx == count - 1)); then
            continue
        fi

        case "${part}" in
            .apm | .github) continue ;;
        esac

        if [[ ${REPO_PATHS_INCLUDE_AGENTS:-false} == "true" ]]; then
            case "${part}" in
                .agents | .claude | .codex | .cursor | .kiro | .vscode) continue ;;
            esac
        fi

        return 0
    done
    return 1
}

#######################################
# repo_path_is_generated_or_agent: Return whether a path is generated or agent-local
#
# Globals:
#   REPO_PATHS_INCLUDE_AGENTS - When true, do not treat agent directories as generated
#
# Arguments:
#   $1 - Repository-relative file path
#
# Outputs:
#   None
#
# Returns:
#   0 when excluded; 1 when the path may be scanned
#
# Usage:
#   repo_path_is_generated_or_agent "apm_modules/foo/bar"
#
#######################################
function repo_path_is_generated_or_agent {
    local path="$1"

    path="${path#./}"

    case "${path}" in
        .git | .git/*) return 0 ;;
        apm_modules | apm_modules/*) return 0 ;;
        node_modules | node_modules/*) return 0 ;;
        dist | dist/*) return 0 ;;
        build | build/*) return 0 ;;
        bin | bin/*) return 0 ;;
    esac

    if [[ ${REPO_PATHS_INCLUDE_AGENTS:-false} == "true" ]]; then
        return 1
    fi

    case "${path}" in
        .agents | .agents/*) return 0 ;;
        .claude | .claude/*) return 0 ;;
        .codex | .codex/*) return 0 ;;
        .cursor | .cursor/*) return 0 ;;
        .kiro | .kiro/*) return 0 ;;
        .vscode | .vscode/*) return 0 ;;
        cursor | cursor/*) return 0 ;;
        kiro | kiro/*) return 0 ;;
    esac

    return 1
}

#######################################
# repo_path_is_gitignored: Return whether git ignores a repository path
#
# Globals:
#   REPO_PATHS_GITIGNORE_CACHE - Memoized git check-ignore results per path
#   REPO_PATHS_INCLUDE_GITIGNORED - When true, never treat paths as ignored
#
# Arguments:
#   $1 - Repository-relative file path
#
# Outputs:
#   None
#
# Returns:
#   0 when git ignores the path; 1 otherwise
#
# Usage:
#   repo_path_is_gitignored "tmp/local-only.txt"
#
#######################################
function repo_path_is_gitignored {
    local path="$1"
    local cache_key="__rp_${path//\//_}"
    cache_key="${cache_key//./_D_}"
    local cache_hit=0
    local cached_value=0

    if [[ -z ${REPO_PATHS_GITIGNORE_CACHE+set} ]]; then
        declare -gA REPO_PATHS_GITIGNORE_CACHE=()
    fi

    if [[ ${REPO_PATHS_INCLUDE_GITIGNORED:-false} == "true" ]]; then
        return 1
    fi
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 1
    fi
    set +u
    if [[ ${REPO_PATHS_GITIGNORE_CACHE[${cache_key}]+set} == set ]]; then
        cache_hit=1
        cached_value="${REPO_PATHS_GITIGNORE_CACHE[${cache_key}]}"
    fi
    set -u
    if [[ ${cache_hit} -eq 1 ]]; then
        [[ ${cached_value} -eq 1 ]]
        return
    fi
    if git check-ignore -q -- "${path}" 2> /dev/null; then
        set +u
        REPO_PATHS_GITIGNORE_CACHE[${cache_key}]=1
        set -u
        return 0
    fi
    set +u
    REPO_PATHS_GITIGNORE_CACHE[${cache_key}]=0
    set -u
    return 1
}

#######################################
# repo_path_matches_extra_prune: Return whether a path matches extra prune roots
#
# Globals:
#   None
#
# Arguments:
#   $1 - Repository-relative file path
#   $@ - Extra repository-relative prune roots
#
# Outputs:
#   None
#
# Returns:
#   0 when matched; 1 otherwise
#
# Usage:
#   repo_path_matches_extra_prune "docs/report/foo.md" docs/report
#
#######################################
function repo_path_matches_extra_prune {
    local path="$1"
    shift
    local extra

    path="${path#./}"
    for extra in "$@"; do
        [[ -z ${extra} ]] && continue
        extra="${extra#./}"
        case "${path}" in
            "${extra}" | "${extra}"/*) return 0 ;;
        esac
    done
    return 1
}

#######################################
# repo_path_should_skip: Return whether a repository path should be excluded
#
# Globals:
#   REPO_PATHS_EXTRA_PRUNES - Comma-separated repository-relative prune roots
#   REPO_PATHS_INCLUDE_AGENTS - When true, do not exclude agent directories
#   REPO_PATHS_INCLUDE_GITIGNORED - When true, do not exclude gitignored paths
#
# Arguments:
#   $1 - Repository-relative file path
#   $@ - Optional extra repository-relative prune roots (merged with REPO_PATHS_EXTRA_PRUNES)
#
# Outputs:
#   None
#
# Returns:
#   0 when excluded; 1 when the path should be scanned
#
# Usage:
#   repo_path_should_skip "node_modules/pkg/index.js"
#
#######################################
function repo_path_should_skip {
    local path="$1"
    shift
    local -a extra_prunes=()

    mapfile -t extra_prunes < <(repo_list_extra_prune_roots "$@")
    repo_path_should_skip_base "${path}" "${extra_prunes[@]}"
}

#######################################
# repo_path_should_skip_base: Compose standard detect path exclusions
#
# Globals:
#   REPO_PATHS_INCLUDE_AGENTS - When true, do not exclude agent directories
#   REPO_PATHS_INCLUDE_GITIGNORED - When true, do not exclude gitignored paths
#
# Arguments:
#   $1 - Repository-relative file path
#   $@ - Optional extra repository-relative prune roots
#
# Outputs:
#   None
#
# Returns:
#   0 when excluded; 1 when the path should be scanned
#
# Usage:
#   repo_path_should_skip_base "${path}" docs/report
#
#######################################
function repo_path_should_skip_base {
    local path="$1"
    shift
    local -a extra_prunes=("$@")

    path="${path#./}"

    if repo_path_is_generated_or_agent "${path}"; then
        return 0
    fi
    if repo_path_has_excluded_dot_directory "${path}"; then
        return 0
    fi
    if repo_path_matches_extra_prune "${path}" "${extra_prunes[@]}"; then
        return 0
    fi
    if repo_path_is_gitignored "${path}"; then
        return 0
    fi
    return 1
}
