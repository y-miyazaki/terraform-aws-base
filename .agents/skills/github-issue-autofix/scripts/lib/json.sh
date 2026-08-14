#!/bin/bash
#######################################
# Description: JSON output utility functions for shell scripts
#
# Usage: source /path/to/scripts/lib/json.sh
#
# Output:
# - None (library file, sourced by other scripts)
#
# Design Rules:
# - Emit helpers require jq (json_object, json_array, json_string_array, json_number)
# - All functions output compact JSON to stdout
# - Values are properly escaped for JSON safety
# - Bash scalars are strings by default; use json_number for numeric JSON fields
# - Literal true, false, and null infer JSON types; valid {…} or […] fragments embed as JSON
#######################################

readonly _JSON_NUMBER_PREFIX=$'\x1eN'

#######################################
# json_escape_string: Escape a string for JSON embedding without jq
#
# Globals:
#   None
#
# Arguments:
#   $1 - String to escape
#
# Outputs:
#   JSON-safe escaped string to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   escaped="$(json_escape_string "path/to \"file\"")"
#
#######################################
function json_escape_string {
    local str="$1"
    local i c ord out=""
    local len=${#str}

    for ((i = 0; i < len; i++)); do
        c="${str:i:1}"
        case "${c}" in
            $'\\')
                out+=$'\\\\'
                ;;
            '"')
                out+='\"'
                ;;
            $'\b')
                out+='\b'
                ;;
            $'\f')
                out+='\f'
                ;;
            $'\n')
                out+='\n'
                ;;
            $'\r')
                out+='\r'
                ;;
            $'\t')
                out+='\t'
                ;;
            *)
                LC_ALL=C printf -v ord '%d' "'${c}"
                if ((ord < 32)); then
                    out+=$(printf '\\u%04x' "${ord}")
                else
                    out+="${c}"
                fi
                ;;
        esac
    done
    printf '%s' "${out}"
}

#######################################
# json_emit_minimal_error: Print a minimal error object without jq
#
# Globals:
#   None
#
# Arguments:
#   $1 - Error message
#
# Outputs:
#   Minimal JSON error object to stdout
#
# Returns:
#   None
#
# Usage:
#   json_emit_minimal_error "Missing required tools: jq"
#
#######################################
function json_emit_minimal_error {
    local message="$1"

    printf '{"status":"error","skip":true,"message":"%s"}\n' "$(json_escape_string "${message}")"
}

#######################################
# json_is_number: Return whether a value is a JSON number literal
#
# Globals:
#   None
#
# Arguments:
#   $1 - Candidate number string
#
# Outputs:
#   None
#
# Returns:
#   0 when the value matches a JSON number; 1 otherwise
#
# Usage:
#   json_is_number "42"
#
#######################################
function json_is_number {
    local value="$1"

    [[ ${value} =~ ^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]
}

#######################################
# json_number: Mark a value for JSON number encoding in json_object/json_array
#
# Globals:
#   _JSON_NUMBER_PREFIX - Internal marker prefix
#
# Arguments:
#   $1 - JSON number literal string
#
# Outputs:
#   Marked number string to stdout
#
# Returns:
#   0 on success; 1 when the value is not a valid JSON number
#
# Usage:
#   json_object line "$(json_number 42)"
#
#######################################
function json_number {
    local value="$1"

    if ! json_is_number "${value}"; then
        printf 'json_number: invalid JSON number: %s\n' "${value}" >&2
        return 1
    fi

    printf '%s%s' "${_JSON_NUMBER_PREFIX}" "${value}"
}

#######################################
# json_append_encoded_value: Append one jq-bound value argument
#
# Globals:
#   _JSON_NUMBER_PREFIX - Internal marker prefix
#
# Arguments:
#   $1 - Value to encode
#   $2 - jq variable name
#   $3 - Name of jq_cmd array variable
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
# Usage:
#   json_append_encoded_value "${value}" "${arg}" jq_cmd
#
#######################################
function json_append_encoded_value {
    local value="$1"
    local arg="$2"
    local -n _jq_cmd="$3"

    if [[ ${value} == "${_JSON_NUMBER_PREFIX}"* ]]; then
        local number="${value#"${_JSON_NUMBER_PREFIX}"}"
        _jq_cmd+=(--argjson "${arg}" "${number}")
        return
    fi

    case "${value}" in
        null)
            _jq_cmd+=(--argjson "${arg}" 'null')
            ;;
        true | false)
            _jq_cmd+=(--argjson "${arg}" "${value}")
            ;;
        *)
            if [[ ${value} == \{* || ${value} == \[* ]] && jq -e . > /dev/null 2>&1 <<< "${value}"; then
                _jq_cmd+=(--argjson "${arg}" "${value}")
            else
                _jq_cmd+=(--arg "${arg}" "${value}")
            fi
            ;;
    esac
}

#######################################
# json_array: Output a JSON array from encoded values or raw JSON fragments
#
# Globals:
#   None
#
# Arguments:
#   $@ - Values to encode (objects/arrays starting with { or [ pass through)
#
# Outputs:
#   JSON array string to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   json_array "a" "b"
#   json_array "${objects[@]}"
#
#######################################
function json_array {
    local -a jq_cmd=(jq -n -c)
    local prog="["
    local sep="" idx=0 arg item value

    if [[ $# -eq 0 ]]; then
        printf '%s' "[]"
        return
    fi

    for item in "$@"; do
        arg="_ja${idx}"
        idx=$((idx + 1))
        value="${item}"

        json_append_encoded_value "${value}" "${arg}" jq_cmd

        prog+="${sep}\$${arg}"
        sep=","
    done

    prog+="]"
    "${jq_cmd[@]}" "${prog}"
}

#######################################
# json_object: Output a JSON object from alternating key/value pairs
#
# Globals:
#   None
#
# Arguments:
#   $1 - Optional --skip-empty flag (omit keys with empty string values)
#   Remaining args - Alternating key/value pairs
#
# Outputs:
#   JSON object string to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   json_object status "ok" skip "false" count "$(json_number 0)"
#   json_object --skip-empty kind "todo" hint ""
#
#######################################
function json_object {
    local skip_empty="false"
    local -a jq_cmd=(jq -n -c)
    local prog="{"
    local sep="" idx=0 key value arg key_arg

    if [[ $# -gt 0 && $1 == "--skip-empty" ]]; then
        skip_empty="true"
        shift
    fi

    if [[ $(($# % 2)) -ne 0 ]]; then
        printf 'json_object: expected even number of key/value arguments\n' >&2
        return 1
    fi

    while [[ $# -gt 0 ]]; do
        key="$1"
        value="$2"
        shift 2

        if [[ ${skip_empty} == "true" && -z ${value} ]]; then
            continue
        fi

        arg="_jo${idx}"
        key_arg="_jk${idx}"
        idx=$((idx + 1))

        jq_cmd+=(--arg "${key_arg}" "${key}")
        json_append_encoded_value "${value}" "${arg}" jq_cmd

        prog+="${sep}(\$${key_arg}): \$${arg}"
        sep=","
    done

    if [[ ${idx} -eq 0 ]]; then
        printf '%s' "{}"
        return
    fi

    prog+="}"
    "${jq_cmd[@]}" "${prog}"
}

#######################################
# json_string_array: Output a bash array as a JSON array of strings
#
# Globals:
#   None
#
# Arguments:
#   $@ - Array elements (pass as "${array[@]}")
#
# Outputs:
#   JSON array string to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   files=("a.txt" "b.txt")
#   json_string_array "${files[@]}"
#   # Output: ["a.txt","b.txt"]
#
#######################################
function json_string_array {
    local -a filtered=()
    local item

    for item in "$@"; do
        if [[ -n ${item} ]]; then
            filtered+=("${item}")
        fi
    done

    if [[ ${#filtered[@]} -eq 0 ]]; then
        printf '%s' "[]"
        return
    fi

    json_array "${filtered[@]}"
}
