#!/bin/bash
#######################################
# Description: Complete Module-by-module Terraform updater with individual validation
# Usage: ./module_updater.sh [options] <terraform_directory>
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for library loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# Global variables
#######################################
VERBOSE=false
DRY_RUN=false
CHECK_ONLY=false
RECURSIVE_SEARCH=false
TERRAFORM_DIR=""
DEFAULT_ENV="${ENV:-dev}"
BACKUP_DIR=""
NO_PLAN=false

# Counters
TOTAL_MODULES=0
UPDATED_MODULES=0
FAILED_MODULES=0

# Arrays for tracking
declare -a UPDATED_MODULES_LIST=()
declare -a FAILED_MODULES_LIST=()

# Associative arrays for module tracking
declare -A MODULE_FILES_MAP=()     # module_source -> list of files
declare -A MODULE_VERSIONS_MAP=()  # module_source -> current_version|latest_version
declare -A PROJECT_DIRS_MAP=()     # project_dir -> 1 (for tracking unique project directories)
declare -A LATEST_VERSION_CACHE=() # module_source -> latest_version cache
declare -A BASELINE_CREATED_MAP=() # project_dir -> 1 when baseline created

# Track current file for better error context on unexpected errors
CURRENT_FILE_BEING_SCANNED=""

# Common patterns to avoid duplication
readonly MODULE_PATTERN_GREP='^[[:space:]]*module[[:space:]]\+"[^"]\+"[[:space:]]*{'
readonly MODULE_PATTERN_AWK='/^[[:space:]]*module[[:space:]]+"[^"]+"[[:space:]]*{/'

# Provide context on unexpected errors (ignored inside conditionals by bash)
trap 'echo "[ERROR] Aborted while processing: ${CURRENT_FILE_BEING_SCANNED:-N/A}" >&2' ERR

#######################################
# show_usage: Display usage information
#
# Description:
#   Display usage information
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   None
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "Description: Update Terraform module versions and validate configurations"
    echo ""
    echo "Options:"
    echo "  -h, --help                 Display this help message"
    echo "  -v, --verbose              Enable verbose output (shows detailed plan content differences)"
    echo "  -d, --dry-run              Run in dry-run mode"
    echo "  -c, --check-only           Check only mode"
    echo "  -r, --recursive            Search recursively"
    echo "  --no-plan                  Skip plan/validation (no plan mode)"
    echo ""
    echo "Arguments:"
    echo "  terraform_directory        Target Terraform directory to process"
    echo ""
    echo "Environment Variables:"
    echo "  ENV              Environment for tfvars file selection (default: dev)"
    echo ""
    echo "Verbose Mode Features:"
    echo "  • Shows detailed terraform plan content differences (baseline vs current)"
    echo "  • Displays error details for failed operations"
    echo "  • Saves detailed diff logs to terraform_show_diff_YYYYMMDD_HHMMSS.log"
    echo "  • Provides summary of resource changes (added/removed/modified)"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") -v terraform/application"
    echo "  $(basename "$0") --dry-run --check-only terraform/base"
    echo "  $(basename "$0") --no-plan terraform/base"
    echo "  $(basename "$0") -v -r terraform/                  # Recursive with verbose output"
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parse command line arguments
#
# Arguments:
#   $@ - Command line arguments
#
# Global Variables:
#   VERBOSE - Enable verbose output
#   DRY_RUN - Run in dry-run mode
#   CHECK_ONLY - Check only mode
#   RECURSIVE_SEARCH - Search recursively
#   NO_PLAN - Skip plan/validation
#   TERRAFORM_DIR - Target Terraform directory
#
# Returns:
#   0 on success, exits on error
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help) show_usage ;;
            -v | --verbose)
                VERBOSE=true
                shift
                ;;
            -d | --dry-run)
                DRY_RUN=true
                shift
                ;;
            -c | --check-only)
                CHECK_ONLY=true
                shift
                ;;
            -r | --recursive)
                RECURSIVE_SEARCH=true
                shift
                ;;
            --no-plan)
                NO_PLAN=true
                shift
                ;;
            -*) error_exit "Unknown option: $1" ;;
            *)
                if [[ -z "$TERRAFORM_DIR" ]]; then
                    TERRAFORM_DIR="$1"
                else
                    error_exit "Unexpected argument: $1"
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$TERRAFORM_DIR" ]]; then
        echo "Error: Terraform directory is required" >&2
        show_usage
    fi

    TERRAFORM_DIR=$(realpath "$TERRAFORM_DIR")
    if [[ ! -d "$TERRAFORM_DIR" ]]; then
        error_exit "Terraform directory does not exist: $TERRAFORM_DIR"
    fi
}

#######################################
# artifact_dir_for: Compute artifact directory for a project
#
# Description:
#   Compute artifact directory for a project
#
# Arguments:
#   $1 - Project directory path
#
# Global Variables:
#   BACKUP_DIR - Main backup directory
#
# Returns:
#   Path to the artifact directory
#
# Usage:
#   artifact_dir_for "/path/to/project"
#
#######################################
function artifact_dir_for {
    local project_dir="$1"
    # sanitize project dir to a filesystem friendly name
    local rel
    rel=$(echo "$project_dir" | sed 's|^/||; s|/|__|g')
    local dir="${BACKUP_DIR}/${rel}"
    mkdir -p "$dir"
    echo "$dir"
}

#######################################
# backup_file: Create a timestamped backup of a file
#
# Description:
#   Creates a timestamped backup copy of the specified file in the appropriate
#   backup directory. Uses project-specific artifact directories to avoid collisions.
#
# Arguments:
#   $1 - Path to file to backup
#
# Returns:
#   Path to the created backup file
#
# Usage:
#   backup_path=$(backup_file "/path/to/terraform.tf")
#
#######################################
function backup_file {
    local file=$1
    local backup_file
    # Place backup files under the project-specific artifact directory to avoid basename collisions
    local project_dir
    project_dir=$(find_terraform_project_root "$file" 2> /dev/null || true)
    local proj_artifacts
    if [[ -n "$project_dir" ]]; then
        proj_artifacts=$(artifact_dir_for "$project_dir")
    else
        proj_artifacts="$BACKUP_DIR"
        mkdir -p "$proj_artifacts"
    fi

    backup_file="${proj_artifacts}/$(basename "$file").$(date +'%Y%m%d_%H%M%S_%N').bak"
    mkdir -p "$(dirname "$backup_file")"
    cp "$file" "$backup_file"
    echo "$backup_file"
}

#######################################
# cleanup_all_artifacts: Clean up all backup and temporary files
#
# Description:
#   Removes all backup directories, plan files, and temporary artifacts
#   created during the module update process.
#
# Arguments:
#   None
#
# Global Variables:
#   BACKUP_DIR - Main backup directory path
#   TERRAFORM_DIR - Base terraform directory
#   RECURSIVE_SEARCH - Whether recursive search was used
#   NO_PLAN - Whether plan mode was disabled
#
# Returns:
#   0 on success
#
# Usage:
#   cleanup_all_artifacts
#
#######################################
function cleanup_all_artifacts {
    log "INFO" "Cleaning up all artifacts..."

    # Cleanup backup directories
    # Remove any runtime backup directory created during this run
    if [[ -n "$BACKUP_DIR" ]] && [[ -d "$BACKUP_DIR" ]]; then
        log "INFO" "Removing backup directory: $BACKUP_DIR"
        rm -rf "$BACKUP_DIR"
    fi

    # Remove all per-project .terraform_backups directories under the terraform root
    local backup_dirs
    readarray -t backup_dirs < <(find "$TERRAFORM_DIR" -type d -name ".terraform_backups" 2> /dev/null || true)

    for backup_dir in "${backup_dirs[@]}"; do
        if [[ -d "$backup_dir" ]]; then
            log "INFO" "Removing backup directory: $backup_dir"
            rm -rf "$backup_dir"
        fi
    done

    # Also remove legacy backup directories named .terraform_module_backups for compatibility
    readarray -t backup_dirs < <(find "$TERRAFORM_DIR" -type d -name ".terraform_module_backups" 2> /dev/null || true)
    for backup_dir in "${backup_dirs[@]}"; do
        if [[ -d "$backup_dir" ]]; then
            log "INFO" "Removing legacy backup directory: $backup_dir"
            rm -rf "$backup_dir"
        fi
    done

    if [[ "$NO_PLAN" == "true" ]]; then
        log "INFO" "--no-plan specified: Skipping plan file cleanup."
        return
    fi

    # Cleanup plan comparison files in all terraform directories
    local terraform_dirs
    if [[ "$RECURSIVE_SEARCH" == "true" ]]; then
        readarray -t terraform_dirs < <(find "$TERRAFORM_DIR" -name "*.tf" -type f -exec dirname {} \; 2> /dev/null | sort -u)
    else
        terraform_dirs=("$TERRAFORM_DIR")
    fi

    for dir in "${terraform_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            cd "$dir" || continue
            local plan_files=(
                .terraform_baseline.plan .terraform_baseline.log .terraform_baseline.txt
                .terraform_current.plan .terraform_current.log .terraform_current.txt
                .terraform_init.log .terraform_validate.log
            )

            for file in "${plan_files[@]}"; do
                if [[ -f "$file" ]]; then
                    rm -f "$file"
                fi
            done

            # Remove terraform show diff log files (both old and new naming)
            find . -maxdepth 1 -name "terraform_show_diff_*.log" -type f -delete 2> /dev/null || true
            find . -maxdepth 1 -name "terraform_plan_diff_*.log" -type f -delete 2> /dev/null || true
        fi
    done

    log "INFO" "✅ All artifacts cleaned up successfully"
}

#######################################
# cleanup_plan_files: Clean up Terraform plan comparison files
#
# Description:
#   Removes temporary plan files and artifacts created during
#   the validation process from the specified Terraform directory.
#
# Arguments:
#   $1 - Path to Terraform directory to clean
#
# Returns:
#   0 on success
#
# Usage:
#   cleanup_plan_files "/path/to/terraform"
#
#######################################
function cleanup_plan_files {
    local terraform_dir="$1"

    cd "$terraform_dir" || return 1

    # Remove plan comparison files
    rm -f .terraform_baseline.plan .terraform_baseline.log .terraform_baseline.txt || true
    rm -f .terraform_current.plan .terraform_current.log .terraform_current.txt || true
    rm -f .terraform_init.log .terraform_validate.log || true

    # Also remove artifact copies under any .terraform_backups for this project
    local proj_backup_dirs
    readarray -t proj_backup_dirs < <(find . -maxdepth 2 -type d -name ".terraform_backups" -print 2> /dev/null || true)
    for b in "${proj_backup_dirs[@]}"; do
        find "$b" -maxdepth 2 -type f -name ".terraform_baseline.*" -delete 2> /dev/null || true
        find "$b" -maxdepth 2 -type f -name ".terraform_current.*" -delete 2> /dev/null || true
        find "$b" -maxdepth 2 -type f -name "terraform_show_diff_*.log" -delete 2> /dev/null || true
    done

    # Remove terraform show diff log files (both old and new naming)
    find . -maxdepth 1 -name "terraform_show_diff_*.log" -type f -delete 2> /dev/null || true
    find . -maxdepth 1 -name "terraform_plan_diff_*.log" -type f -delete 2> /dev/null || true

    log "INFO" "Plan comparison files cleaned up"
}

#######################################
# collect_module_for_batch_update: Collect module information for batch update
#
# Description:
#   Collect module information for batch update
#
# Arguments:
#   $1 - Path to Terraform file
#   $2 - Module source identifier
#   $3 - Current version string
#   $4 - Latest version string
#
# Global Variables:
#   MODULE_FILES_MAP - Map of module source to list of files
#   MODULE_VERSIONS_MAP - Map of module source to version info
#   PROJECT_DIRS_MAP - Map of project dir to 1
#
# Returns:
#   None
#
# Usage:
#   collect_module_for_batch_update "main.tf" "module-source" "1.0.0" "2.0.0"
#
#######################################
function collect_module_for_batch_update {
    local file="$1"
    local module_source="$2"
    local current_version="$3"
    local latest_version="$4"

    # Store file information for this module
    if [[ -v MODULE_FILES_MAP[$module_source] ]]; then
        MODULE_FILES_MAP[$module_source]="${MODULE_FILES_MAP[$module_source]}|$file"
    else
        MODULE_FILES_MAP[$module_source]="$file"
    fi

    # Store version information
    MODULE_VERSIONS_MAP[$module_source]="$current_version|$latest_version"

    # Track project directories
    local terraform_project_dir
    terraform_project_dir=$(find_terraform_project_root "$file")
    PROJECT_DIRS_MAP[$terraform_project_dir]=1

    log "INFO" "Collected: $module_source ($current_version -> $latest_version) in $(basename "$file")"
}

#######################################
# create_baseline_plan: Create baseline terraform plan before module updates
#
# Description:
#   Create baseline terraform plan before module updates
#
# Arguments:
#   $1 - Terraform directory
#   $2 - Environment (optional)
#
# Global Variables:
#   ENV - Environment variable
#   DEFAULT_ENV - Default environment
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   create_baseline_plan "/path/to/terraform" "dev"
#
#######################################
function create_baseline_plan {
    local terraform_dir="$1"
    # Use the provided env parameter; if not provided prefer exported ENV, otherwise DEFAULT_ENV
    local env="${2:-${ENV:-$DEFAULT_ENV}}"

    cd "$terraform_dir" || return 1

    log "INFO" "Creating baseline plan before module update..."

    # Debug output for troubleshooting
    echo "[DEBUG] Current directory: $(pwd)"
    echo "[DEBUG] Directory listing:" && ls -l
    echo "[DEBUG] ENV: $env"
    set -x

    # Check for backend configuration file
    local backend_config="terraform.${env}.tfbackend"
    local init_options=()

    if [[ -f "$backend_config" ]]; then
        init_options+=("-reconfigure" "-backend-config=$backend_config")
    fi

    # Initialize terraform
    if ! terraform init "${init_options[@]}" > /dev/null 2>&1; then
        set +x
        log "ERROR" "Initial terraform init failed"
        if [[ "$VERBOSE" == "true" ]]; then
            log "ERROR" "Init error - running in verbose mode"
            # shellcheck disable=SC2086
            terraform init "${init_options[@]}"
        fi
        return 1
    fi
    set +x

    # Create baseline plan and write artifacts to the backup artifacts dir for this project
    local tfvars_file="terraform.${env}.tfvars"
    local plan_options=""
    if [[ -f "$tfvars_file" ]]; then
        plan_options="-var-file=$tfvars_file"
    fi

    local proj_artifacts
    proj_artifacts=$(artifact_dir_for "$(pwd)")

    local baseline_plan_file="${proj_artifacts}/.terraform_baseline.plan"
    local baseline_log_file="${proj_artifacts}/.terraform_baseline.log"

    local baseline_plan_command="terraform plan -lock=false -out=${baseline_plan_file}"
    if [[ -n "$plan_options" ]]; then
        baseline_plan_command="$baseline_plan_command $plan_options"
    fi

    if ! $baseline_plan_command > "${baseline_log_file}" 2>&1; then
        log "ERROR" "Failed to create baseline plan"
        if [[ "$VERBOSE" == "true" ]]; then
            echo_section "BASELINE PLAN ERROR OUTPUT"
            log "ERROR" "Command failed: $baseline_plan_command"
            log "ERROR" "Error details:"
            cat "${baseline_log_file}"
            echo ""
        fi
        return 1
    fi

    log "INFO" "✅ Baseline plan created successfully (artifacts: ${proj_artifacts})"
    # Clean up any transient logs in the working dir
    rm -f .terraform_init.log .terraform_validate.log || true
    return 0
}

#######################################
# create_baseline_plans_for_projects: Create baseline plans for all affected projects
#
# Description:
#   Create baseline plans for all affected projects
#
# Arguments:
#   None
#
# Global Variables:
#   PROJECT_DIRS_MAP - Map of project dir to 1
#   BASELINE_CREATED_MAP - Map of project dir to baseline creation status
#   ENV - Environment variable
#   DEFAULT_ENV - Default environment
#
# Returns:
#   None
#
# Usage:
#   create_baseline_plans_for_projects
#
#######################################
function create_baseline_plans_for_projects {
    echo_section "Creating baseline plans for affected projects"

    for project_dir in "${!PROJECT_DIRS_MAP[@]}"; do
        # Sanitize keys: remove surrounding quotes and trim newlines/whitespace
        local proj
        proj="${project_dir//\"/}"
        proj="${proj//\'/}"
        # remove CR/LF and trim leading/trailing spaces
        proj=$(printf '%s' "$proj" | tr -d '\r\n' | sed 's/^\s*//;s/\s*$//')

        log "INFO" "Creating baseline plan for: $proj"
        # Prefer exported ENV if set, otherwise fall back to DEFAULT_ENV
        if create_baseline_plan "$proj" "${ENV:-$DEFAULT_ENV}"; then
            BASELINE_CREATED_MAP[$proj]=1
        else
            # In normal (no --no-plan) mode, failing to create a baseline plan should be an error.
            log "ERROR" "Failed to create baseline plan for: $proj"
            error_exit "Cannot proceed without baseline plans"
        fi
    done
}

#######################################
# extract_modules_from_file: Extract module source and version information from a Terraform file
#
# Description:
#   Parses a Terraform file to extract module declarations and their
#   source/version information using AWK pattern matching.
#
# Arguments:
#   $1 - Path to Terraform file to parse
#
# Returns:
#   Lines in format "source||version||filename"
#
# Usage:
#   modules=$(extract_modules_from_file "main.tf")
#
#######################################
function extract_modules_from_file {
    local file="$1"
    # Extract module blocks and find source/version pairs robustly (POSIX awk, nested block aware)
    awk '
    BEGIN { in_module=0; block=""; nest=0; }
    '"$MODULE_PATTERN_AWK"' {
      in_module=1; block = $0 "\n"; nest=1; next;
    }
    in_module {
      block = block $0 "\n";
      if ($0 ~ /{/) nest++;
      if ($0 ~ /}/) nest--;
      if (nest == 0) {
        source=""; version="";
        if (match(block, /source[[:space:]]*=[[:space:]]*\"[^\"]+\"/)) {
          s = substr(block, RSTART, RLENGTH);
          gsub(/.*=[[:space:]]*\"/, "", s);
          gsub(/\".*/, "", s);
          source = s;
        }
        if (match(block, /version[[:space:]]*=[[:space:]]*\"[^\"]+\"/)) {
          s = substr(block, RSTART, RLENGTH);
          gsub(/.*=[[:space:]]*\"/, "", s);
          gsub(/\".*/, "", s);
          version = s;
        }
        if (length(source) > 0 && length(version) > 0) { print source "||" version "||" FILENAME; }
        in_module=0; block="";
      }
      next;
    }
  ' "$file"
}

#######################################
# find_terraform_modules: Find all Terraform files containing module declarations
#
# Description:
#   Searches for .tf files that contain module declarations. Supports both
#   single directory and recursive search modes.
#
# Arguments:
#   $1 - Directory to search in
#   $2 - Whether to search recursively (true/false, default: false)
#
# Returns:
#   List of file paths containing module declarations
#
# Usage:
#   files=$(find_terraform_modules "/path/to/terraform" "true")
#
#######################################
function find_terraform_modules {
    local dir="$1"
    local search_recursive="${2:-false}"

    if [[ "$search_recursive" == "true" ]]; then
        # Use anchored, more precise pattern and avoid aborting on grep non-zero statuses
        find "$dir" -name "*.tf" -type f -not -path "*/.terraform/*" \
            -exec grep -l "$MODULE_PATTERN_GREP" {} \; 2> /dev/null || true
    else
        find "$dir" -maxdepth 1 -name "*.tf" -type f \
            -exec grep -l "$MODULE_PATTERN_GREP" {} \; 2> /dev/null || true
    fi
}

#######################################
# find_terraform_project_root: Find the root directory of a Terraform project
#
# Description:
#   Traverses up the directory tree from a given file to find the
#   Terraform project root by looking for characteristic files.
#
# Arguments:
#   $1 - Path to a file within the Terraform project
#
# Returns:
#   Path to the Terraform project root directory
#
# Usage:
#   root=$(find_terraform_project_root "modules/vpc/main.tf")
#
#######################################
function find_terraform_project_root {
    local file_path="$1"
    local current_dir
    current_dir=$(dirname "$file_path")

    # Look for terraform configuration files that indicate a project root
    while [[ "$current_dir" != "/" ]]; do
        # Check for backend config files or variables files
        if [[ -f "$current_dir/terraform.dev.tfbackend" ]] || [[ -f "$current_dir/terraform.dev.tfvars" ]] || [[ -f "$current_dir/main.tf" ]]; then
            echo "$current_dir"
            return 0
        fi

        # Also check for terraform directory structure patterns
        if [[ -f "$current_dir/versions.tf" ]] || [[ -f "$current_dir/providers.tf" ]]; then
            echo "$current_dir"
            return 0
        fi

        current_dir=$(dirname "$current_dir")
    done

    # If no project root found, return the file's directory
    # shellcheck disable=SC2086
    # shellcheck disable=SC2005
    echo "$(dirname \"$file_path\")"
}

#######################################
# get_latest_version: Retrieve the latest version of a Terraform module from registry
#
# Description:
#   Queries the Terraform Registry API to get the latest available version
#   for a given module source. Supports caching to avoid repeated API calls.
#
# Arguments:
#   $1 - Module source URL/path
#
# Returns:
#   Latest version string or "unknown" if unable to determine
#
# Usage:
#   latest=$(get_latest_version "terraform-aws-modules/vpc/aws")
#
#######################################
function get_latest_version {
    local module_source=$1
    local base_module="$module_source"

    # Return cached result if available
    if [[ -n "${LATEST_VERSION_CACHE[$module_source]:-}" ]]; then
        echo "${LATEST_VERSION_CACHE[$module_source]}"
        return 0
    fi

    # Skip non-registry sources (git/https, ssh, local paths)
    if [[ "$module_source" =~ ^git:: ]] \
        || [[ "$module_source" =~ ^(https?|ssh)://.*\.git(/|$) ]] \
        || [[ "$module_source" =~ ^(github\.com|git@) ]] \
        || [[ "$module_source" =~ ^(~|/|\./|\.\./) ]]; then
        LATEST_VERSION_CACHE[$module_source]="unknown"
        echo "unknown"
        return 0
    fi

    # Handle submodules
    if [[ "$module_source" =~ ^(.+)//modules/ ]]; then
        base_module="${BASH_REMATCH[1]}"
    fi

    # API endpoints
    local api_base="https://registry.terraform.io/v1/modules/${base_module}"
    local api_versions="${api_base}/versions"

    # Try versions endpoint (preferred and stable)
    local response latest
    if response=$(timeout 12s curl -sf --connect-timeout 5 --max-time 10 "$api_versions" 2> /dev/null); then
        latest=$(echo "$response" | jq -r '
            ( .versions // empty | map(.version) )
            // ( .modules // empty | first | .versions // empty | map(.version) )
            | select(length>0)
            | sort_by(split(".")|map(tonumber? // 0))
            | last
        ' 2> /dev/null || echo "")
        if [[ -n "$latest" && "$latest" != "null" ]]; then
            LATEST_VERSION_CACHE[$module_source]="$latest"
            echo "$latest"
            return 0
        fi
    fi

    # Fallback to module base endpoint (may include .version for some registries)
    if response=$(timeout 12s curl -sf --connect-timeout 5 --max-time 10 "$api_base" 2> /dev/null); then
        latest=$(echo "$response" | jq -r '(.version // empty) // empty' 2> /dev/null || echo "")
        if [[ -n "$latest" && "$latest" != "null" ]]; then
            LATEST_VERSION_CACHE[$module_source]="$latest"
            echo "$latest"
            return 0
        fi
    fi

    LATEST_VERSION_CACHE[$module_source]="unknown"
    echo "unknown"
    return 0
}

#######################################
# generate_summary_report: Generate and display update summary report
#
# Description:
#   Creates a comprehensive summary of the module update process,
#   showing statistics and lists of successful/failed updates.
#
# Arguments:
#   None
#
# Global Variables:
#   TOTAL_MODULES - Total modules scanned
#   UPDATED_MODULES - Number of successfully updated modules
#   FAILED_MODULES - Number of failed module updates
#   UPDATED_MODULES_LIST - List of successfully updated modules
#   FAILED_MODULES_LIST - List of failed modules
#
# Returns:
#   0 on success
#
# Usage:
#   generate_summary_report
#
#######################################
function generate_summary_report {
    echo_section "Update Summary Report"

    echo "📊 Statistics:"
    echo "  Total modules scanned: $TOTAL_MODULES"
    echo "  Modules updated: $UPDATED_MODULES"
    echo "  Modules failed: $FAILED_MODULES"
    echo ""

    if [[ ${#UPDATED_MODULES_LIST[@]} -gt 0 ]]; then
        echo "✅ Successfully updated modules:"
        for module in "${UPDATED_MODULES_LIST[@]}"; do
            echo "  - $module"
        done
        echo ""
    fi

    if [[ ${#FAILED_MODULES_LIST[@]} -gt 0 ]]; then
        echo "❌ Failed to update modules:"
        for module in "${FAILED_MODULES_LIST[@]}"; do
            echo "  - $module"
        done
        echo ""
    fi
}

#######################################
# process_batch_module_updates: Process all collected modules in batch
#
# Description:
#   Process all collected modules in batch
#
# Arguments:
#   None
#
# Global Variables:
#   MODULE_FILES_MAP - Map of module source to list of files
#   MODULE_VERSIONS_MAP - Map of module source to version info
#   UPDATED_MODULES - Counter for updated modules
#   FAILED_MODULES - Counter for failed modules
#   UPDATED_MODULES_LIST - List of updated modules
#   FAILED_MODULES_LIST - List of failed modules
#   NO_PLAN - Skip plan/validation flag
#
# Returns:
#   None
#
# Usage:
#   process_batch_module_updates
#
#######################################
function process_batch_module_updates {
    local total_modules=${#MODULE_FILES_MAP[@]}
    local current_module=0

    if [[ $total_modules -eq 0 ]]; then
        log "INFO" "No modules to update"
        return 0
    fi

    echo_section "Batch Module Updates ($total_modules modules)"

    if [[ "$NO_PLAN" != "true" ]]; then
        # Create baseline plans for all affected projects
        create_baseline_plans_for_projects
    else
        log "INFO" "--no-plan specified: Skipping baseline plan creation and validation."
    fi

    # Process each module
    for module_source in "${!MODULE_FILES_MAP[@]}"; do
        current_module=$((current_module + 1))
        echo "🔄 [$current_module/$total_modules] Processing module: $module_source"

        local version_info="${MODULE_VERSIONS_MAP[$module_source]}"
        local current_version="${version_info%|*}"
        local latest_version="${version_info#*|}"
        local files_list="${MODULE_FILES_MAP[$module_source]}"

        # Split files and update all at once
        IFS='|' read -ra files_array <<< "$files_list"

        local update_success=true
        local updated_files=()

        # Update all files for this module
        for file in "${files_array[@]}"; do
            if update_module_version "$file" "$module_source" "$current_version" "$latest_version"; then
                updated_files+=("$file")
                log "INFO" "✅ Updated $module_source in $(basename "$file")"
            else
                log "ERROR" "❌ Failed to update $module_source in $(basename "$file")"
                update_success=false
                break
            fi
        done

        if [[ "$update_success" == "true" ]]; then
            if [[ "$NO_PLAN" != "true" ]]; then
                # Validate all affected projects
                if validate_all_affected_projects "${files_array[@]}"; then
                    UPDATED_MODULES=$((UPDATED_MODULES + 1))
                    UPDATED_MODULES_LIST+=("$module_source ($current_version -> $latest_version) [${#files_array[@]} files]")
                    log "INFO" "✅ Successfully updated and validated $module_source in ${#files_array[@]} files"
                else
                    log "WARN" "❌ Validation failed for $module_source, rolling back all files..."
                    rollback_module_files "$module_source" "${updated_files[@]}"
                    FAILED_MODULES=$((FAILED_MODULES + 1))
                    FAILED_MODULES_LIST+=("$module_source")
                fi
            else
                # No plan/validation mode: treat as success
                UPDATED_MODULES=$((UPDATED_MODULES + 1))
                UPDATED_MODULES_LIST+=("$module_source ($current_version -> $latest_version) [${#files_array[@]} files] (no plan mode)")
                log "INFO" "✅ Updated $module_source in ${#files_array[@]} files (no plan mode)"
            fi
        else
            # Rollback any successful updates for this module
            if [[ ${#updated_files[@]} -gt 0 ]]; then
                log "WARN" "❌ Partial update failure for $module_source, rolling back successful updates..."
                rollback_module_files "$module_source" "${updated_files[@]}"
            fi
            FAILED_MODULES=$((FAILED_MODULES + 1))
            FAILED_MODULES_LIST+=("$module_source")
        fi
    done
}

#######################################
# process_single_module_update: Process update for a single module instance
#
# Description:
#   Handles the update process for a single module occurrence.
#   In dry-run mode, just counts the update. Otherwise, collects
#   module information for batch processing.
#
# Arguments:
#   $1 - Path to Terraform file
#   $2 - Module source identifier
#   $3 - Current version string
#   $4 - Latest version string
#
# Returns:
#   0 on success
#
# Usage:
#   process_single_module_update "main.tf" "module-source" "1.0.0" "2.0.0"
#
#######################################
function process_single_module_update {
    local file="$1"
    local module_source="$2"
    local current_version="$3"
    local latest_version="$4"

    if [[ "$DRY_RUN" == "true" ]]; then
        #    echo "📦 Would update: $module_source: $current_version -> $latest_version in $(basename "$file")"
        UPDATED_MODULES=$((UPDATED_MODULES + 1))
        return 0
    fi

    # For batch processing, just collect module information
    collect_module_for_batch_update "$file" "$module_source" "$current_version" "$latest_version"
}

#######################################
# process_terraform_directory: Process all Terraform files in a directory
#
# Description:
#   Main processing function that scans a Terraform directory for modules,
#   identifies updates, and processes them either individually or in batch.
#
# Arguments:
#   $1 - Path to Terraform directory to process
#
# Returns:
#   0 on success
#
# Usage:
#   process_terraform_directory "/path/to/terraform"
#
#######################################
function process_terraform_directory {
    local terraform_dir="$1"

    echo_section "Processing: $(basename "$terraform_dir")"
    cd "$terraform_dir" || {
        error_exit "Failed to change to directory: $terraform_dir"
        return 1
    }

    # Setup backup directory for actual updates
    if [[ "$DRY_RUN" == "false" ]] && [[ "$CHECK_ONLY" == "false" ]]; then
        setup_backup_directory
    fi

    # Find terraform files with modules
    local terraform_files
    readarray -t terraform_files < <(find_terraform_modules "$terraform_dir" "$RECURSIVE_SEARCH")

    if [[ ${#terraform_files[@]} -eq 0 ]]; then
        log "INFO" "No Terraform files with modules found"
        return 0
    fi

    log "INFO" "Found ${#terraform_files[@]} files with modules"

    # Process each file
    for file in "${terraform_files[@]}"; do
        CURRENT_FILE_BEING_SCANNED="$file"
        local file_basename
        file_basename=$(basename "$file")
        log "INFO" "Scanning file: $file_basename"

        # Extract modules from file
        local modules_info
        # Guard against awk non-zero exit with set -e
        modules_info="$(extract_modules_from_file "$file" || true)"
        if [[ "$VERBOSE" == "true" ]]; then
            echo "[DEBUG] modules_info for $file:" >&2
            echo "$modules_info" >&2
        fi
        while IFS= read -r module_line; do
            [[ -z "$module_line" ]] && continue
            TOTAL_MODULES=$((TOTAL_MODULES + 1))
            if [[ "$VERBOSE" == "true" ]]; then
                echo "[DEBUG] TOTAL_MODULES incremented: $TOTAL_MODULES ($module_line)" >&2
            fi

            local module_source="${module_line%%||*}"
            local remaining="${module_line#*||}"
            local current_version="${remaining%%||*}"

            log "INFO" "Found module: $module_source (current: $current_version)"

            if [[ "$CHECK_ONLY" == "true" ]]; then
                echo "📦 Found: $module_source (current: $current_version) in $file_basename"
                continue
            fi

            # Get latest version (robust + cached)
            local latest_version
            latest_version=$(get_latest_version "$module_source")

            if [[ "$latest_version" == "unknown" ]]; then
                log "WARN" "Could not determine latest version for $module_source; skipping"
                continue
            fi

            if [[ "$current_version" == "$latest_version" ]]; then
                log "INFO" "Module $module_source is already up to date ($current_version)"
                continue
            fi

            # Process individual module update
            echo "📦 Update available: $module_source: $current_version -> $latest_version in $file_basename"
            process_single_module_update "$file" "$module_source" "$current_version" "$latest_version"

        done <<< "$modules_info"
        log "INFO" "Finished scanning: $file_basename"
    done

    # After scanning all files, process batch updates
    if [[ "$DRY_RUN" == "false" ]] && [[ "$CHECK_ONLY" == "false" ]]; then
        process_batch_module_updates
    fi

    # Note: Backup files will be cleaned up by cleanup_all_artifacts function at the end
    # This preserves them during execution for rollback purposes
}

#######################################
# rollback_module_files: Rollback module files to their backup versions
#
# Description:
#   Restores files from backup copies when module updates fail.
#   Searches for appropriate backup files in project-specific directories.
#
# Arguments:
#   $1 - Module source identifier
#   $@ - List of file paths to rollback
#
# Returns:
#   0 on success
#
# Usage:
#   rollback_module_files "module-source" "file1.tf" "file2.tf"
#
#######################################
function rollback_module_files {
    local module_source="$1"
    shift
    local files=("$@")

    for file in "${files[@]}"; do
        local target_backup=""

        # Try project-specific artifact dir first
        local project_dir
        project_dir=$(find_terraform_project_root "$file" 2> /dev/null || true)
        if [[ -n "$project_dir" ]]; then
            local proj_artifacts
            proj_artifacts=$(artifact_dir_for "$project_dir")
            if [[ -d "$proj_artifacts" ]]; then
                # pick the newest backup by mtime
                target_backup=$(find "$proj_artifacts" -maxdepth 1 -type f -name "$(basename "$file").*.bak" -printf '%T@ %p\n' 2> /dev/null | sort -n | awk '{print $2}' | tail -n1 || true)
            fi
        fi

        # Fallback: search runtime BACKUP_DIR
        if [[ -z "$target_backup" && -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
            target_backup=$(find "$BACKUP_DIR" -maxdepth 2 -type f -name "$(basename "$file").*.bak" -printf '%T@ %p\n' 2> /dev/null | sort -n | awk '{print $2}' | tail -n1 || true)
        fi

        # Legacy fallback
        if [[ -z "$target_backup" ]]; then
            target_backup=$(find "$TERRAFORM_DIR" -type d -name ".terraform_module_backups" -exec find {} -maxdepth 1 -type f -name "$(basename "$file").*.bak" -printf '%T@ %p\n' \; 2> /dev/null | sort -n | awk '{print $2}' | tail -n1 || true)
        fi

        if [[ -n "$target_backup" && -f "$target_backup" ]]; then
            cp "$target_backup" "$file"
            log "INFO" "Rolled back $module_source in $(basename "$file") (from $target_backup)"
        else
            log "ERROR" "❌ No backup file found for rollback: $(basename "$file")"
        fi
    done
}

#######################################
# setup_backup_directory: Create a timestamped backup directory for file changes
#
# Description:
#   Creates a backup directory with timestamp under the terraform directory
#   to store original files before making modifications.
#
# Arguments:
#   None
#
# Global Variables:
#   TERRAFORM_DIR - Base terraform directory
#   BACKUP_DIR - Set to the created backup directory path
#
# Returns:
#   0 on success
#
# Usage:
#   setup_backup_directory
#
#######################################
function setup_backup_directory {
    # New unified backup directory name (was .terraform_module_backups)
    BACKUP_DIR="${TERRAFORM_DIR}/.terraform_backups/$(date +'%Y%m%d_%H%M%S')"
    mkdir -p "$BACKUP_DIR"
    log "INFO" "Backup directory created: $BACKUP_DIR"
}

#######################################
# update_module_version: Update a module version in a Terraform file
#
# Description:
#   Updates the version field of a specific module in a Terraform file.
#   Creates a backup before making changes and can restore on failure.
#
# Arguments:
#   $1 - Path to Terraform file
#   $2 - Module source identifier
#   $3 - Current version string
#   $4 - New version string
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   update_module_version "main.tf" "terraform-aws-modules/vpc/aws" "3.0.0" "4.0.0"
#
#######################################
function update_module_version {
    local file="$1"
    local module_source="$2"
    local current_version="$3"
    local new_version="$4"

    log "INFO" "Updating $module_source: $current_version -> $new_version in $(basename "$file")"

    # Create backup
    local backup_file
    backup_file=$(backup_file "$file")

    # Update version using sed
    local escaped_current
    # shellcheck disable=SC2016
    escaped_current=$(printf '%s\n' "$current_version" | sed 's/[[\.*^$()+?{|]/\\&/g')
    local escaped_new
    # shellcheck disable=SC2016
    escaped_new=$(printf '%s\n' "$new_version" | sed 's/[[\.*^$()+?{|]/\\&/g')

    if sed -i.tmp "s/version[[:space:]]*=[[:space:]]*\"${escaped_current}\"/version = \"${escaped_new}\"/" "$file"; then
        rm -f "$file.tmp"
        log "INFO" "✅ Successfully updated $module_source in $(basename "$file")"
        return 0
    else
        # Restore from backup on failure
        cp "$backup_file" "$file"
        rm -f "$file.tmp"
        log "ERROR" "❌ Failed to update $module_source in $(basename "$file")"
        return 1
    fi
}

#######################################
# validate_all_affected_projects: Validate all affected projects
#
# Description:
#   Validate all affected projects
#
# Arguments:
#   $@ - List of file paths
#
# Global Variables:
#   BASELINE_CREATED_MAP - Map of project dir to baseline creation status
#   ENV - Environment variable
#   DEFAULT_ENV - Default environment
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   validate_all_affected_projects "file1.tf" "file2.tf"
#
#######################################
function validate_all_affected_projects {
    local files=("$@")
    local project_dirs_to_validate=()

    # Get unique project directories from the files
    for file in "${files[@]}"; do
        local project_dir
        project_dir=$(find_terraform_project_root "$file")

        # Check if project_dir already exists in array
        local dir_exists=false
        for existing_dir in "${project_dirs_to_validate[@]}"; do
            if [[ "$existing_dir" == "$project_dir" ]]; then
                dir_exists=true
                break
            fi
        done

        if [[ "$dir_exists" == "false" ]]; then
            project_dirs_to_validate+=("$project_dir")
        fi
    done

    # Validate each project
    for project_dir in "${project_dirs_to_validate[@]}"; do
        # Skip validation if baseline plan could not be created for this project
        if [[ -z "${BASELINE_CREATED_MAP[$project_dir]:-}" ]]; then
            log "WARN" "Skipping validation for project (no baseline): $project_dir"
            continue
        fi

        log "INFO" "Validating project: $project_dir"
        # Prefer exported ENV if set, otherwise fall back to DEFAULT_ENV
        if ! validate_terraform_with_plan_comparison "$project_dir" "${ENV:-$DEFAULT_ENV}"; then
            log "ERROR" "Validation failed for project: $project_dir"
            return 1
        fi
    done

    log "INFO" "✅ All affected projects validated successfully"
    return 0
}

#######################################
# validate_terraform_with_plan_comparison: Validate terraform with plan content comparison
#
# Description:
#   Validate terraform with plan content comparison
#
# Arguments:
#   $1 - Terraform directory
#   $2 - Environment (optional)
#
# Global Variables:
#   ENV - Environment variable
#   DEFAULT_ENV - Default environment
#   VERBOSE - Enable verbose output
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   validate_terraform_with_plan_comparison "/path/to/terraform" "dev"
#
#######################################
function validate_terraform_with_plan_comparison {
    local terraform_dir="$1"
    # Use the provided env parameter; if not provided prefer exported ENV, otherwise DEFAULT_ENV
    local env="${2:-${ENV:-$DEFAULT_ENV}}"

    cd "$terraform_dir" || return 1

    log "INFO" "Validating Terraform configuration with plan content comparison..."

    # Check for backend configuration file
    local backend_config="terraform.${env}.tfbackend"
    local init_options=("-input=false" "-upgrade")

    if [[ -f "$backend_config" ]]; then
        init_options+=("-reconfigure" "-backend-config=$backend_config")
    fi

    # Re-initialize to ensure new module version is downloaded
    log "INFO" "Re-initializing Terraform to download updated modules..."
    local proj_artifacts
    proj_artifacts=$(artifact_dir_for "$(pwd)")
    local init_log_file="${proj_artifacts}/.terraform_init.log"
    if ! terraform init "${init_options[@]}" > "${init_log_file}" 2>&1; then
        log "ERROR" "Terraform init failed after module update"
        if [[ "$VERBOSE" == "true" ]]; then
            echo_section "TERRAFORM INIT ERROR OUTPUT"
            log "ERROR" "Init command failed with options: ${init_options[*]}"
            log "ERROR" "Error details:"
            cat "${init_log_file}"
            echo ""
        fi
        return 1
    fi

    # Validate syntax after init
    if ! terraform validate > .terraform_validate.log 2>&1; then
        log "ERROR" "Terraform syntax validation failed"
        if [[ "$VERBOSE" == "true" ]]; then
            echo_section "TERRAFORM VALIDATE ERROR OUTPUT"
            log "ERROR" "Validation failed, error details:"
            cat .terraform_validate.log
            echo ""
        fi
        return 1
    fi

    # Create current plan and compare with baseline; place artifacts into project artifacts dir
    local tfvars_file="terraform.${env}.tfvars"
    local plan_options=""
    if [[ -f "$tfvars_file" ]]; then
        plan_options="-var-file=$tfvars_file"
    fi

    local proj_artifacts
    proj_artifacts=$(artifact_dir_for "$(pwd)")
    local current_plan_file="${proj_artifacts}/.terraform_current.plan"
    local current_log_file="${proj_artifacts}/.terraform_current.log"

    local current_plan_command="terraform plan -lock=false -out=${current_plan_file}"
    if [[ -n "$plan_options" ]]; then
        current_plan_command="$current_plan_command $plan_options"
    fi

    if ! $current_plan_command > "${current_log_file}" 2>&1; then
        log "ERROR" "Failed to create current plan"
        if [[ "$VERBOSE" == "true" ]]; then
            echo_section "CURRENT PLAN ERROR OUTPUT"
            log "ERROR" "Command failed: $current_plan_command"
            log "ERROR" "Error details:"
            cat "${current_log_file}"
            echo ""
        fi
        return 1
    fi

    # Compare plan file contents using 'terraform show' from artifacts
    terraform show -no-color "${proj_artifacts}/.terraform_baseline.plan" > "${proj_artifacts}/.terraform_baseline.txt" 2> /dev/null
    terraform show -no-color "${proj_artifacts}/.terraform_current.plan" > "${proj_artifacts}/.terraform_current.txt" 2> /dev/null

    if diff -q "${proj_artifacts}/.terraform_baseline.txt" "${proj_artifacts}/.terraform_current.txt" > /dev/null 2>&1; then
        log "INFO" "✅ No infrastructure changes detected"
        # Clean up transient plan files in working dir (artifact copies kept)
        rm -f .terraform_baseline.plan .terraform_baseline.log .terraform_baseline.txt || true
        rm -f .terraform_current.plan .terraform_current.log .terraform_current.txt || true
        rm -f .terraform_init.log .terraform_validate.log || true
        return 0
    else
        log "WARN" "⚠️  Infrastructure changes detected between baseline and current plan"
        if [[ "$VERBOSE" == "true" ]]; then
            echo_section "TERRAFORM SHOW DIFFERENCES DETECTED"
            log "INFO" "Detailed plan content differences (baseline vs current):"
            echo ""

            # Show unified diff with context (use artifact files)
            if command -v colordiff > /dev/null 2>&1; then
                diff -u "${proj_artifacts}/.terraform_baseline.txt" "${proj_artifacts}/.terraform_current.txt" | colordiff
            else
                diff -u "${proj_artifacts}/.terraform_baseline.txt" "${proj_artifacts}/.terraform_current.txt"
            fi

            echo ""
            echo_section "SUMMARY OF CHANGES"

            # Count and summarize changes
            local added_resources
            local removed_resources
            local modified_resources

            added_resources=$(diff "${proj_artifacts}/.terraform_baseline.txt" "${proj_artifacts}/.terraform_current.txt" | grep -c "^+.*resource\|^+.*data\." || true)
            removed_resources=$(diff "${proj_artifacts}/.terraform_baseline.txt" "${proj_artifacts}/.terraform_current.txt" | grep -c "^-.*resource\|^-.*data\." || true)
            modified_resources=$(diff "${proj_artifacts}/.terraform_baseline.txt" "${proj_artifacts}/.terraform_current.txt" | grep -c "^[+-].*~\|^[+-].*-/+\|^[+-].*force replacement" || true)

            log "INFO" "Resources to be added: $added_resources"
            log "INFO" "Resources to be removed: $removed_resources"
            log "INFO" "Resources to be modified: $modified_resources"

            # Save detailed diff to log file for later review
            local diff_log_file
            diff_log_file="${proj_artifacts}/terraform_show_diff_$(date +%Y%m%d_%H%M%S).log"

            {
                echo "# Terraform Show Differences - $(date)"
                echo "# Directory: $(pwd)"
                echo "# Baseline vs Current Plan Content Comparison"
                echo ""
                diff -u "${proj_artifacts}/.terraform_baseline.txt" "${proj_artifacts}/.terraform_current.txt"
            } > "$diff_log_file"

            log "INFO" "Detailed diff saved to: $diff_log_file"
            echo ""
        else
            log "INFO" "Use -v option to see detailed plan content differences"
        fi
        # Clean up transient plan files in working dir (artifact copies kept)
        rm -f .terraform_baseline.plan .terraform_baseline.log .terraform_baseline.txt || true
        rm -f .terraform_current.plan .terraform_current.log .terraform_current.txt || true
        rm -f .terraform_init.log .terraform_validate.log || true
        return 1
    fi
}

#######################################
# main: Main execution function
#
# Description:
#   Main execution function
#
# Arguments:
#   $@ - Command line arguments
#
# Global Variables:
#   TERRAFORM_DIR - Target Terraform directory
#   RECURSIVE_SEARCH - Search recursively flag
#   CHECK_ONLY - Check only mode flag
#   DRY_RUN - Dry-run mode flag
#   FAILED_MODULES - Counter for failed modules
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    parse_arguments "$@"

    # Validate dependencies
    validate_dependencies "terraform" "curl" "jq"

    echo_section "Complete Module-by-Module Updater"
    log "INFO" "Target directory: $TERRAFORM_DIR"
    log "INFO" "Recursive search: $RECURSIVE_SEARCH"
    log "INFO" "Mode: $(
        if [[ "$CHECK_ONLY" == "true" ]]; then
            echo "CHECK-ONLY"
        elif [[ "$DRY_RUN" == "true" ]]; then
            echo "DRY-RUN"
        else
            echo "UPDATE"
        fi
    )"

    local start_time
    start_time=$(date +%s)

    process_terraform_directory "$TERRAFORM_DIR"

    generate_summary_report

    # Cleanup backup directories and plan files
    cleanup_all_artifacts

    local end_time
    end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    log "INFO" "Process completed in ${elapsed} seconds"

    echo_section "Process completed"

    # Exit with appropriate code
    if [[ $FAILED_MODULES -gt 0 ]]; then
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
