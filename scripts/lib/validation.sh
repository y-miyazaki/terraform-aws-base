#!/bin/bash
#######################################
# Description: Validation utility functions for shell scripts
# Usage: source /path/to/scripts/lib/validation.sh
#
# This library provides validation functions:
# - File and directory validation
# - Script syntax validation
# - Permission validation
# - Configuration validation
#######################################

# Ensure common.sh is loaded for logging functions
if ! declare -f log > /dev/null 2>&1; then
    # Try to source common.sh from the same directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=./common.sh
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/common.sh"
fi

#######################################
# validate_config_format: Validate configuration file format
#
# Description:
#   Validates a configuration file based on its format type
#
# Arguments:
#   $1 - Configuration file path
#   $2 - Format type (json, yaml, ini, etc.)
#
# Returns:
#   0 if valid, 1 if invalid
#
# Usage:
#   if validate_config_format "config.json" "json"; then echo "Valid"; fi
#
#######################################
function validate_config_format {
    local config_file="$1"
    local format_type="$2"

    case "${format_type,,}" in
        json)
            validate_json_file "$config_file"
            ;;
        yaml | yml)
            validate_yaml_file "$config_file"
            ;;
        *)
            log "WARN" "Configuration format validation not implemented for: $format_type"
            validate_file_exists "$config_file" "Configuration file"
            ;;
    esac
}

#######################################
# validate_directory_exists: Validate directory exists and is accessible
#
# Description:
#   Checks that a directory exists and is accessible
#
# Arguments:
#   $1 - Directory path
#   $2 - Description (optional, for error messages)
#
# Returns:
#   None (exits on validation failure)
#
# Usage:
#   validate_directory_exists "/path/to/dir" "Configuration directory"
#
#######################################
function validate_directory_exists {
    local dir_path="$1"
    local description="${2:-Directory}"

    if [[ ! -d "$dir_path" ]]; then
        error_exit "$description not found: $dir_path"
    fi

    if [[ ! -r "$dir_path" ]]; then
        error_exit "$description is not accessible: $dir_path"
    fi

    log "DEBUG" "$description validated: $dir_path"
}

#######################################
# validate_file_exists: Validate file exists and is readable
#
# Description:
#   Checks that a file exists and is readable
#
# Arguments:
#   $1 - File path
#   $2 - Description (optional, for error messages)
#
# Returns:
#   None (exits on validation failure)
#
# Usage:
#   validate_file_exists "/path/to/file.txt" "Configuration file"
#
#######################################
function validate_file_exists {
    local file_path="$1"
    local description="${2:-File}"

    if [[ ! -f "$file_path" ]]; then
        error_exit "$description not found: $file_path"
    fi

    if [[ ! -r "$file_path" ]]; then
        error_exit "$description is not readable: $file_path"
    fi

    log "DEBUG" "$description validated: $file_path"
}

#######################################
# validate_file_permissions: Validate file permissions
#
# Description:
#   Checks that a file has the required permissions
#
# Arguments:
#   $1 - File path
#   $2 - Required permissions (e.g., "755", "644")
#
# Returns:
#   0 if permissions are correct, 1 if incorrect
#
# Usage:
#   if validate_file_permissions "script.sh" "755"; then echo "Correct"; fi
#
#######################################
function validate_file_permissions {
    local file_path="$1"
    local required_perms="$2"

    validate_file_exists "$file_path" "File"

    local current_perms
    current_perms=$(stat -c "%a" "$file_path" 2> /dev/null)

    if [[ "$current_perms" == "$required_perms" ]]; then
        log "DEBUG" "File permissions correct ($current_perms): $file_path"
        return 0
    else
        log "ERROR" "File permissions incorrect (expected: $required_perms, actual: $current_perms): $file_path"
        return 1
    fi
}

#######################################
# validate_files_in_directory: Validate multiple files in directory
#
# Description:
#   Validates all files with a specific extension in a directory
#
# Arguments:
#   $1 - Directory path
#   $2 - File extension (e.g., "sh", "json", "tf")
#   $3 - Validation function name
#
# Returns:
#   0 if all files are valid, 1 if any file is invalid
#
# Usage:
#   if validate_files_in_directory "/scripts" "sh" "validate_script_syntax"; then echo "All valid"; fi
#
#######################################
function validate_files_in_directory {
    local dir_path="$1"
    local extension="$2"
    local validation_function="$3"
    local failed_count=0

    validate_directory_exists "$dir_path"

    # Find files with specified extension
    local files
    mapfile -t files < <(find "$dir_path" -type f -name "*.${extension}" 2> /dev/null)

    if [[ ${#files[@]} -eq 0 ]]; then
        log "INFO" "No .$extension files found in: $dir_path"
        return 0
    fi

    log "INFO" "Validating ${#files[@]} .$extension files in: $dir_path"

    for file in "${files[@]}"; do
        if ! "$validation_function" "$file"; then
            failed_count=$((failed_count + 1))
            log "ERROR" "Validation failed: $file"
        fi
    done

    if [[ $failed_count -eq 0 ]]; then
        log "INFO" "All .$extension files validated successfully"
        return 0
    else
        log "ERROR" "$failed_count .$extension files failed validation"
        return 1
    fi
}

#######################################
# validate_json_file: Validate JSON file syntax
#
# Description:
#   Validates that a file contains valid JSON syntax
#
# Arguments:
#   $1 - JSON file path
#
# Returns:
#   0 if valid JSON, 1 if invalid
#
# Usage:
#   if validate_json_file "config.json"; then echo "Valid JSON"; fi
#
#######################################
function validate_json_file {
    local json_file="$1"

    validate_file_exists "$json_file" "JSON file"

    if jq empty "$json_file" > /dev/null 2>&1; then
        log "DEBUG" "JSON file is valid: $json_file"
        return 0
    else
        log "ERROR" "JSON file is invalid: $json_file"
        return 1
    fi
}

#######################################
# validate_network_connectivity: Validate network connectivity
#
# Description:
#   Tests network connectivity to a host or URL
#
# Arguments:
#   $1 - Host/URL to test
#   $2 - Timeout in seconds (optional, defaults to 5)
#
# Returns:
#   0 if reachable, 1 if not reachable
#
# Usage:
#   if validate_network_connectivity "https://example.com"; then echo "Reachable"; fi
#
#######################################
function validate_network_connectivity {
    local host="$1"
    local timeout="${2:-5}"

    if command -v curl > /dev/null 2>&1; then
        if curl -s --max-time "$timeout" --head "$host" > /dev/null 2>&1; then
            log "DEBUG" "Network connectivity confirmed: $host"
            return 0
        fi
    elif command -v wget > /dev/null 2>&1; then
        if wget -q --timeout="$timeout" --spider "$host" > /dev/null 2>&1; then
            log "DEBUG" "Network connectivity confirmed: $host"
            return 0
        fi
    else
        log "WARN" "Cannot test network connectivity (curl or wget not available)"
        return 0
    fi

    log "ERROR" "Network connectivity failed: $host"
    return 1
}

#######################################
# validate_script_executable: Validate script executable permissions
#
# Description:
#   Checks that a script file has executable permissions
#
# Arguments:
#   $1 - Script file path
#
# Returns:
#   0 if executable, 1 if not executable
#
# Usage:
#   if validate_script_executable "script.sh"; then echo "Executable"; fi
#
#######################################
function validate_script_executable {
    local script_path="$1"

    validate_file_exists "$script_path" "Script file"

    if [[ -x "$script_path" ]]; then
        log "DEBUG" "Script is executable: $script_path"
        return 0
    else
        log "ERROR" "Script is not executable: $script_path"
        return 1
    fi
}

#######################################
# validate_script_syntax: Validate shell script syntax
#
# Description:
#   Validates the syntax of a shell script using bash -n
#
# Arguments:
#   $1 - Script file path
#
# Returns:
#   0 if syntax is valid, 1 if invalid
#
# Usage:
#   if validate_script_syntax "script.sh"; then echo "Valid"; fi
#
#######################################
function validate_script_syntax {
    local script_path="$1"

    validate_file_exists "$script_path" "Script file"

    # Check if file has shebang
    local first_line
    first_line=$(head -n1 "$script_path")
    if [[ ! "$first_line" =~ ^#! ]]; then
        log "WARN" "Script missing shebang: $script_path"
    fi

    # Validate syntax with bash
    if bash -n "$script_path" 2> /dev/null; then
        log "DEBUG" "Script syntax valid: $script_path"
        return 0
    else
        log "ERROR" "Script syntax error in: $script_path"
        return 1
    fi
}

#######################################
# validate_port_availability: Validate port availability
#
# Description:
#   Tests if a network port is open and available on a host
#
# Arguments:
#   $1 - Host
#   $2 - Port
#   $3 - Timeout in seconds (optional, defaults to 3)
#
# Returns:
#   0 if port is open, 1 if closed or unreachable
#
# Usage:
#   if validate_port_availability "localhost" "8080"; then echo "Port open"; fi
#
#######################################
function validate_port_availability {
    local host="$1"
    local port="$2"
    local timeout="${3:-3}"

    if command -v nc > /dev/null 2>&1; then
        if nc -z -w "$timeout" "$host" "$port" > /dev/null 2>&1; then
            log "DEBUG" "Port is available: $host:$port"
            return 0
        fi
    elif command -v telnet > /dev/null 2>&1; then
        if timeout "$timeout" telnet "$host" "$port" < /dev/null > /dev/null 2>&1; then
            log "DEBUG" "Port is available: $host:$port"
            return 0
        fi
    else
        log "WARN" "Cannot test port availability (nc or telnet not available)"
        return 0
    fi

    log "ERROR" "Port is not available: $host:$port"
    return 1
}

#######################################
# validate_yaml_file: Validate YAML file syntax
#
# Description:
#   Validates that a file contains valid YAML syntax
#
# Arguments:
#   $1 - YAML file path
#
# Returns:
#   0 if valid YAML, 1 if invalid
#
# Usage:
#   if validate_yaml_file "config.yaml"; then echo "Valid YAML"; fi
#
#######################################
function validate_yaml_file {
    local yaml_file="$1"

    validate_file_exists "$yaml_file" "YAML file"

    # Try yq first, then python with yaml module
    if command -v yq > /dev/null 2>&1; then
        if yq eval 'true' "$yaml_file" > /dev/null 2>&1; then
            log "DEBUG" "YAML file is valid: $yaml_file"
            return 0
        fi
    elif command -v python3 > /dev/null 2>&1; then
        # Check if the PyYAML package is available. If not, warn and return success
        # so callers that can't validate still pass. This avoids failing when
        # python3 is present but PyYAML is not installed in the environment.
        if ! python3 -c "import pkgutil; assert pkgutil.find_loader('yaml') is not None" > /dev/null 2>&1; then
            log "WARN" "PyYAML not available; cannot validate YAML file: $yaml_file"
            return 0
        fi

        if python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" > /dev/null 2>&1; then
            log "DEBUG" "YAML file is valid: $yaml_file"
            return 0
        fi
    else
        log "WARN" "Cannot validate YAML file (yq or python3 not available): $yaml_file"
        return 0
    fi

    log "ERROR" "YAML file is invalid: $yaml_file"
    return 1
}
