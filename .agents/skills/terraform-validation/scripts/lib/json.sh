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
# - No external dependencies (no jq required)
# - All functions output to stdout
# - Values are properly escaped for JSON safety
#######################################

#######################################
# json_escape: Escape a string for safe JSON embedding
#
# Arguments:
#   $1 - String to escape
#
# Global Variables:
#   None
#
# Returns:
#   JSON-safe escaped string (to stdout)
#
# Usage:
#   escaped=$(json_escape "path/to \"file\"")
#
#######################################
function json_escape {
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
# json_string_array: Output a bash array as a JSON array of strings
#
# Arguments:
#   $@ - Array elements (pass as "${array[@]}")
#
# Global Variables:
#   None
#
# Returns:
#   JSON array string (to stdout)
#
# Usage:
#   files=("a.txt" "b.txt")
#   json_string_array "${files[@]}"
#   # Output: ["a.txt", "b.txt"]
#
#######################################
function json_string_array {
    local -a items=("$@")
    local i len result

    # Filter out empty strings
    local -a filtered=()
    for i in "${!items[@]}"; do
        if [[ -n ${items[i]} ]]; then
            filtered+=("${items[i]}")
        fi
    done

    len=${#filtered[@]}
    if [[ ${len} -eq 0 ]]; then
        printf '%s' "[]"
        return
    fi

    result="["

    for ((i = 0; i < len; i++)); do
        local escaped
        escaped="$(json_escape "${filtered[i]}")"
        result+="\"${escaped}\""
        if [[ $i -lt $((len - 1)) ]]; then
            result+=", "
        fi
    done

    result+="]"
    printf '%s' "${result}"
}

#######################################
# json_object_start: Print opening brace with optional indentation
#
# Arguments:
#   $1 - Indent level (optional, default 0)
#
# Global Variables:
#   None
#
# Returns:
#   None (outputs to stdout)
#
# Usage:
#   json_object_start
#
#######################################
function json_object_start {
    echo "{"
}

#######################################
# json_object_end: Print closing brace
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   None (outputs to stdout)
#
# Usage:
#   json_object_end
#
#######################################
function json_object_end {
    echo "}"
}

#######################################
# json_field_string: Output a JSON key-value pair (string value)
#
# Arguments:
#   $1 - Key name
#   $2 - String value
#   $3 - Trailing comma ("," or "", default ",")
#
# Global Variables:
#   None
#
# Returns:
#   None (outputs to stdout)
#
# Usage:
#   json_field_string "status" "ok" ","
#   json_field_string "message" "done" ""
#
#######################################
function json_field_string {
    local key="$1"
    local value="$2"
    local comma="${3-,}"
    local escaped
    escaped="$(json_escape "${value}")"
    echo "  \"${key}\": \"${escaped}\"${comma}"
}

#######################################
# json_field_bool: Output a JSON key-value pair (boolean value)
#
# Arguments:
#   $1 - Key name
#   $2 - Boolean value ("true" or "false")
#   $3 - Trailing comma ("," or "", default ",")
#
# Global Variables:
#   None
#
# Returns:
#   None (outputs to stdout)
#
# Usage:
#   json_field_bool "skip" "true" ","
#
#######################################
function json_field_bool {
    local key="$1"
    local value="$2"
    local comma="${3-,}"
    echo "  \"${key}\": ${value}${comma}"
}

#######################################
# json_field_array: Output a JSON key-value pair (array value)
#
# Arguments:
#   $1 - Key name
#   $2 - JSON array string (from json_string_array)
#   $3 - Trailing comma ("," or "", default ",")
#
# Global Variables:
#   None
#
# Returns:
#   None (outputs to stdout)
#
# Usage:
#   arr=$(json_string_array "${files[@]}")
#   json_field_array "files" "${arr}" ""
#
#######################################
function json_field_array {
    local key="$1"
    local array_value="$2"
    local comma="${3-,}"
    echo "  \"${key}\": ${array_value}${comma}"
}
