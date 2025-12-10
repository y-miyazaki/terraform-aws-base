#!/bin/bash
#######################################
# Description: Generate database schema documentation using SchemaSpy via AWS Bastion and Secrets Manager
# Usage: ./aws_schemaspy.sh [options]
#   options:
#     -h, --help           Display this help message
#     -v, --verbose        Enable verbose output
#     -d, --dry-run        Show what would be done without executing
#     -e, --environment    Environment name (dev, qa, stg, prd) (required)
#     -t, --db-type        Database type (pgsql, pgsql11, mysql, redshift) (default: pgsql11)
#     -n, --db-name        Database name (required)
#     -s, --schema-name    Schema name to document (optional: if not specified, uses -all to document all schemas)
#     -o, --output-dir     Output directory for generated documentation (optional)
#     -p, --local-port     Local port for port forwarding (default: 15432 for pgsql, 15439 for redshift, 13306 for mysql)
#     --secret-id          AWS Secrets Manager secret ID (default: {environment}/db/credentials)
#     --bastion-id         EC2 Bastion instance ID (auto-detected if not specified)
#     --bastion-tag        EC2 tag filter for Bastion auto-detection (default: *bastion*)
#     --schemaspy-version  SchemaSpy version to use (default: 6.2.4)
#     --ssl-mode           SSL mode (require, verify-full, verify-ca, disable) (default: require)
#     --db-threads         Number of database threads for parallel processing (default: 3)
#     --skip-cleanup       Skip SSM session cleanup (for debugging)
#
# Output:
# - Generates HTML documentation with ER diagrams in output directory
# - Default output: /workspace/tmp/schemaspy-{environment}-{db_type}-{db_name}-{timestamp}
# - Creates index.html and comprehensive database documentation
#
# Design Rules:
# - Auto-detects Bastion instance via EC2 tags if not specified
# - Uses AWS Secrets Manager for database credentials
# - Establishes SSM Session Manager port forwarding to remote database
# - Automatic cleanup of SSM sessions via trap handlers
# - Validates all AWS resources before execution
# - Supports PostgreSQL, MySQL, Oracle, and Amazon Redshift databases
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
# Global variables and default values
#######################################
VERBOSE=false
export VERBOSE
DRY_RUN=false
ENVIRONMENT=""
DB_TYPE="pgsql11"
DB_NAME=""
SCHEMA_NAME="" # Empty means all schemas will be documented
OUTPUT_DIR=""
LOCAL_PORT=""
SECRET_ID=""
BASTION_ID=""
BASTION_TAG="*bastion*"
SCHEMASPY_VERSION="7.0.2"
SSL_MODE="require"
SKIP_CLEANUP=false
DB_THREADS="3" # Database threads for parallel processing (default: 3 for stability)

# Runtime variables
SSM_PID=""
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# File paths
SCHEMASPY_JAR=""
JDBC_DRIVER=""

#######################################
# show_usage: Display usage information
#
# Description:
#   Displays usage information for the script, including options and examples
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
show_usage() {
    cat << EOF
Usage: $(basename "$0") [options]

Description: Generate database schema documentation using SchemaSpy via AWS Bastion and Secrets Manager.

Required Options:
  -e, --environment    Environment name (dev, qa, stg, prd)
  -n, --db-name        Database name

Optional Options:
  -h, --help           Display this help message
  -v, --verbose        Enable verbose output
  -d, --dry-run        Show what would be done without executing
  -t, --db-type        Database type (pgsql, pgsql11, mysql, redshift) (default: pgsql11)
  -s, --schema-name    Schema name to document (optional: if not specified, uses -all to document all schemas)
  -o, --output-dir     Output directory (default: /workspace/tmp/schemaspy-{env}-{type}-{db})
  -p, --local-port     Local port for port forwarding (default: auto-detected by db-type)
  --ssl-mode           SSL mode for database connection (require, verify-full, verify-ca, disable) (default: require)
  --secret-id          AWS Secrets Manager secret ID (default: {environment}/db/credentials)
  --bastion-id         EC2 Bastion instance ID (auto-detected if not specified)
  --bastion-tag        EC2 tag filter for Bastion (default: *bastion*)
  --schemaspy-version  SchemaSpy version (default: 6.2.4)
  --db-threads         Number of database threads for parallel processing (default: 5 for stability)
  --skip-cleanup       Skip SSM session cleanup (for debugging)

Examples:
  $(basename "$0") -e dev -t mysql    -n myapp        --bastion-id i-0123456789abcdef0
  $(basename "$0") -e dev -t pgsql11  -n aurora_dev   -s public --secret-id dev/db/credentials
  $(basename "$0") -e dev -t redshift -n redshift_dev           --secret-id dev/redshift/credentials

Workflow:
  1. Validates required parameters and AWS connectivity
  2. Auto-detects or uses specified Bastion instance
  3. Retrieves database credentials from Secrets Manager
  4. Establishes SSM port forwarding to database via Bastion
  5. Downloads SchemaSpy and JDBC drivers if not cached
  6. Generates HTML documentation with ER diagrams
  7. Automatically cleans up SSM sessions on exit

Output:
  - HTML documentation: {output_dir}/index.html
  - ER diagrams: {output_dir}/diagrams/
  - Table details: {output_dir}/tables/

EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and options
#
# Arguments:
#   $@ - Command line arguments
#
# Global Variables:
#   VERBOSE - Enable verbose output
#   DRY_RUN - Enable dry-run mode
#   ENVIRONMENT - Environment name
#   DB_TYPE - Database type
#   DB_NAME - Database name
#   SCHEMA_NAME - Schema name to document
#   OUTPUT_DIR - Output directory
#   LOCAL_PORT - Local port for port forwarding
#   SECRET_ID - AWS Secrets Manager secret ID
#   BASTION_ID - EC2 Bastion instance ID
#   BASTION_TAG - EC2 tag filter for Bastion
#   SCHEMASPY_VERSION - SchemaSpy version
#   SSL_MODE - SSL mode for database connection
#   DB_THREADS - Number of database threads
#   SKIP_CLEANUP - Skip SSM session cleanup
#
# Returns:
#   None
#
# Usage:
#   parse_arguments "$@"
#
#######################################
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help)
                show_usage
                ;;
            -v | --verbose)
                VERBOSE=true
                shift
                ;;
            -d | --dry-run)
                DRY_RUN=true
                shift
                ;;
            -e | --environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -t | --db-type)
                DB_TYPE="$2"
                shift 2
                ;;
            -n | --db-name)
                DB_NAME="$2"
                shift 2
                ;;
            -s | --schema-name)
                SCHEMA_NAME="$2"
                shift 2
                ;;
            -o | --output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -p | --local-port)
                LOCAL_PORT="$2"
                shift 2
                ;;
            --secret-id)
                SECRET_ID="$2"
                shift 2
                ;;
            --bastion-id)
                BASTION_ID="$2"
                shift 2
                ;;
            --bastion-tag)
                BASTION_TAG="$2"
                shift 2
                ;;
            --schemaspy-version)
                SCHEMASPY_VERSION="$2"
                shift 2
                ;;
            --ssl-mode)
                SSL_MODE="$2"
                shift 2
                ;;
            --db-threads)
                DB_THREADS="$2"
                shift 2
                ;;
            --skip-cleanup)
                SKIP_CLEANUP=true
                shift
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                error_exit "Unexpected argument: $1"
                ;;
        esac
    done
}

#######################################
# validate_parameters: Validate required parameters
#
# Description:
#   Validates required parameters and sets default values
#
# Arguments:
#   None
#
# Global Variables:
#   ENVIRONMENT - Environment name
#   DB_NAME - Database name
#   SECRET_ID - AWS Secrets Manager secret ID
#   OUTPUT_DIR - Output directory
#   LOCAL_PORT - Local port for port forwarding
#   DB_TYPE - Database type
#   SCHEMA_NAME - Schema name to document
#   SSL_MODE - SSL mode for database connection
#   SCHEMASPY_VERSION - SchemaSpy version
#   DB_THREADS - Number of database threads
#
# Returns:
#   None
#
# Usage:
#   validate_parameters
#
#######################################
validate_parameters() {
    log "INFO" "Validating parameters..."

    if [ -z "${ENVIRONMENT}" ]; then
        error_exit "Environment is required. Use -e or --environment"
    fi

    if [ -z "${DB_NAME}" ]; then
        error_exit "Database name is required. Use -n or --db-name"
    fi

    # Set default secret ID if not specified
    if [ -z "${SECRET_ID}" ]; then
        SECRET_ID="${ENVIRONMENT}/db/credentials"
    fi

    # Set default output directory if not specified
    if [ -z "${OUTPUT_DIR}" ]; then
        OUTPUT_DIR="/workspace/tmp/schemaspy-${ENVIRONMENT}-${DB_TYPE}-${DB_NAME}"
    fi

    # Set default local port based on database type if not specified
    if [ -z "${LOCAL_PORT}" ]; then
        case "${DB_TYPE}" in
            pgsql | pgsql11)
                LOCAL_PORT="15432"
                ;;
            redshift)
                LOCAL_PORT="15439"
                ;;
            mysql)
                LOCAL_PORT="13306"
                ;;
            *)
                LOCAL_PORT="15432"
                log "WARN" "Unknown database type: ${DB_TYPE}, using default port 15432"
                ;;
        esac
        log "DEBUG" "Auto-detected local port: ${LOCAL_PORT}"
    fi

    log "DEBUG" "Configuration:"
    log "DEBUG" "  Environment: ${ENVIRONMENT}"
    log "DEBUG" "  DB Type: ${DB_TYPE}"
    log "DEBUG" "  DB Name: ${DB_NAME}"
    if [ -n "${SCHEMA_NAME}" ]; then
        log "DEBUG" "  Schema Name: ${SCHEMA_NAME} (specific schema)"
    else
        log "DEBUG" "  Schema Name: ALL (-all flag will be used)"
    fi
    log "DEBUG" "  Secret ID: ${SECRET_ID}"
    log "DEBUG" "  Output Directory: ${OUTPUT_DIR}"
    log "DEBUG" "  Local Port: ${LOCAL_PORT}"
    log "DEBUG" "  SSL Mode: ${SSL_MODE}"
    log "DEBUG" "  SchemaSpy Version: ${SCHEMASPY_VERSION}"
    log "DEBUG" "  DB Threads: ${DB_THREADS}"
}

#######################################
# Cleanup function to ensure SSM session is always terminated
#######################################
cleanup() {
    local exit_code=$?

    if [ "${SKIP_CLEANUP}" = true ]; then
        log "WARN" "Cleanup skipped (--skip-cleanup specified)"
        return
    fi

    # First, try to kill the specific PID if we have it
    if [ -n "${SSM_PID}" ] && ps -p "${SSM_PID}" > /dev/null 2>&1; then
        log "INFO" "Cleaning up SSM session (PID: ${SSM_PID})..."
        kill "${SSM_PID}" 2> /dev/null || true
        sleep 1

        # Force kill if still running
        if ps -p "${SSM_PID}" > /dev/null 2>&1; then
            kill -9 "${SSM_PID}" 2> /dev/null || true
        fi
    fi

    # Also clean up any session-manager-plugin processes on our port
    if [ -n "${LOCAL_PORT}" ]; then
        local remaining_pids
        remaining_pids=$(pgrep -f "session-manager-plugin.*${LOCAL_PORT}" 2> /dev/null || true)
        if [ -n "${remaining_pids}" ]; then
            log "INFO" "Cleaning up remaining SSM sessions on port ${LOCAL_PORT}..."
            pkill -TERM -f "session-manager-plugin.*${LOCAL_PORT}" 2> /dev/null || true
            sleep 2
            # Force kill any that are still running
            pkill -9 -f "session-manager-plugin.*${LOCAL_PORT}" 2> /dev/null || true
        fi
    fi

    # Verify port is released
    if [ -n "${LOCAL_PORT}" ] && lsof -i:"${LOCAL_PORT}" > /dev/null 2>&1; then
        log "WARN" "Port ${LOCAL_PORT} is still in use after cleanup"
    else
        log "INFO" "SSM session terminated and port ${LOCAL_PORT} released"
    fi

    exit "${exit_code}"
}

#######################################
# Auto-detect Bastion instance
#######################################
detect_bastion() {
    log "INFO" "Auto-detecting Bastion instance..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would auto-detect Bastion"
        BASTION_ID="i-dryrun123456789"
        return 0
    fi

    BASTION_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=${BASTION_TAG}" "Name=instance-state-name,Values=running" \
        --query 'Reservations[0].Instances[0].InstanceId' \
        --output text)

    if [ -z "${BASTION_ID}" ] || [ "${BASTION_ID}" = "None" ]; then
        error_exit "No running Bastion instance found with tag Name=${BASTION_TAG}"
    fi

    log "INFO" "Found Bastion instance: ${BASTION_ID}"
}

#######################################
# Retrieve credentials from Secrets Manager
#######################################
retrieve_credentials() {
    log "INFO" "Fetching credentials from AWS Secrets Manager..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would retrieve credentials from ${SECRET_ID}"
        DB_HOST="db.example.com"
        DB_PORT="5432"
        DB_USER="dbuser"
        DB_PASSWORD="***"
        return 0
    fi

    local secret_json
    secret_json=$(aws secretsmanager get-secret-value \
        --secret-id "${SECRET_ID}" \
        --query SecretString \
        --output text)

    if [ -z "${secret_json}" ]; then
        error_exit "Failed to retrieve secret: ${SECRET_ID}"
    fi

    log "INFO" "Successfully retrieved secret"

    # Parse credentials (supporting custom key names)
    DB_HOST=$(echo "${secret_json}" | jq -r '.host_read // .host // empty')
    DB_PORT=$(echo "${secret_json}" | jq -r '.port // empty')
    DB_USER=$(echo "${secret_json}" | jq -r '.username // empty')
    DB_PASSWORD=$(echo "${secret_json}" | jq -r '.password // empty')

    if [ -z "${DB_HOST}" ] || [ -z "${DB_PORT}" ] || [ -z "${DB_USER}" ] || [ -z "${DB_PASSWORD}" ]; then
        error_exit "Missing required credentials in secret JSON"
    fi

    log "INFO" "Parsed connection parameters:"
    log "INFO" "  Remote Host: ${DB_HOST}"
    log "INFO" "  Remote Port: ${DB_PORT}"
    log "INFO" "  Database: ${DB_NAME}"
    log "INFO" "  Username: ${DB_USER}"
}

#######################################
# Verify Bastion connectivity
#######################################
verify_bastion() {
    log "INFO" "Verifying Bastion connectivity via Session Manager..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would verify Bastion connectivity"
        return 0
    fi

    local ssm_status
    ssm_status=$(aws ssm describe-instance-information \
        --filters "Key=InstanceIds,Values=${BASTION_ID}" \
        --query 'InstanceInformationList[0].PingStatus' \
        --output text)

    if [ "${ssm_status}" != "Online" ]; then
        error_exit "Bastion instance is not online in Session Manager. Status: ${ssm_status}"
    fi

    log "INFO" "Bastion is online and ready"
}

#######################################
# Start SSM port forwarding
#######################################
start_port_forwarding() {
    # Clean up any existing sessions on this port first
    local existing_pids
    existing_pids=$(pgrep -f "session-manager-plugin.*${LOCAL_PORT}" 2> /dev/null || true)
    if [ -n "${existing_pids}" ]; then
        log "WARN" "Found existing SSM sessions on port ${LOCAL_PORT}, cleaning up..."
        pkill -TERM -f "session-manager-plugin.*${LOCAL_PORT}" 2> /dev/null || true
        sleep 2
        pkill -9 -f "session-manager-plugin.*${LOCAL_PORT}" 2> /dev/null || true
        sleep 1
    fi

    # Verify port is free
    if lsof -i:"${LOCAL_PORT}" > /dev/null 2>&1; then
        error_exit "Port ${LOCAL_PORT} is still in use. Please free it manually: pkill -9 -f 'session-manager-plugin.*${LOCAL_PORT}'"
    fi

    log "INFO" "Starting SSM port forwarding..."
    log "INFO" "  Mapping: localhost:${LOCAL_PORT} -> ${BASTION_ID} -> ${DB_HOST}:${DB_PORT}"

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would start SSM port forwarding"
        SSM_PID="dry-run"
        return 0
    fi

    local ssm_log="/tmp/ssm-session-${TIMESTAMP}.log"

    # Start port forwarding in background
    aws ssm start-session \
        --target "${BASTION_ID}" \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters "{\"host\":[\"${DB_HOST}\"],\"portNumber\":[\"${DB_PORT}\"],\"localPortNumber\":[\"${LOCAL_PORT}\"]}" \
        > "${ssm_log}" 2>&1 &

    SSM_PID=$!
    log "INFO" "SSM Session PID: ${SSM_PID}"

    # Wait for port forwarding to be established
    log "INFO" "Waiting for port forwarding to be established..."
    local max_wait=30
    local elapsed=0

    while [ ${elapsed} -lt ${max_wait} ]; do
        # Check if SSM process is still running
        if ! ps -p "${SSM_PID}" > /dev/null 2>&1; then
            error_exit "SSM session process died unexpectedly. Check log: ${ssm_log}"
        fi

        # Check log for successful port opening
        if grep -q "Port ${LOCAL_PORT} opened" "${ssm_log}" 2> /dev/null \
            && grep -q "Waiting for connections" "${ssm_log}" 2> /dev/null; then
            log "INFO" "Port forwarding is ready on localhost:${LOCAL_PORT}"
            sleep 2 # Give additional time for port to be fully ready
            return 0
        fi

        sleep 1
        elapsed=$((elapsed + 1))

        # Show progress every 5 seconds
        if [ $((elapsed % 5)) -eq 0 ] && [ ${elapsed} -gt 0 ]; then
            log "DEBUG" "${elapsed}/${max_wait} seconds: Still waiting for port forwarding..."
        fi
    done

    error_exit "Port forwarding failed to start within ${max_wait} seconds. Check log: ${ssm_log}"
}

#######################################
# Download SchemaSpy and JDBC drivers
#######################################
download_dependencies() {
    log "INFO" "Checking SchemaSpy and JDBC driver..."

    local cache_dir="/workspace/tmp"
    SCHEMASPY_JAR="${cache_dir}/schemaspy.jar"
    JDBC_DRIVER="${cache_dir}/${DB_TYPE}-jdbc.jar"

    # Download SchemaSpy if not cached
    if [ ! -f "${SCHEMASPY_JAR}" ]; then
        log "INFO" "Downloading SchemaSpy ${SCHEMASPY_VERSION}..."
        curl -fsSL "https://github.com/schemaspy/schemaspy/releases/download/v${SCHEMASPY_VERSION}/schemaspy-app.jar" \
            -o "${SCHEMASPY_JAR}"
        log "INFO" "SchemaSpy downloaded"
    else
        log "DEBUG" "SchemaSpy already cached"
    fi

    # Download JDBC driver if not cached
    if [ ! -f "${JDBC_DRIVER}" ]; then
        log "INFO" "Downloading JDBC driver for ${DB_TYPE}..."
        case "${DB_TYPE}" in
            pgsql | pgsql11)
                curl -fsSL "https://jdbc.postgresql.org/download/postgresql-42.7.5.jar" \
                    -o "${JDBC_DRIVER}"
                ;;
            redshift)
                curl -fsSL "https://s3.amazonaws.com/redshift-downloads/drivers/jdbc/2.1.0.32/redshift-jdbc42-2.1.0.32.jar" \
                    -o "${JDBC_DRIVER}"
                ;;
            mysql)
                curl -fsSL "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar" \
                    -o "${JDBC_DRIVER}"
                ;;
            *)
                error_exit "Unsupported database type: ${DB_TYPE}"
                ;;
        esac
        log "INFO" "JDBC driver downloaded"
    else
        log "DEBUG" "JDBC driver already cached"
    fi
}

#######################################
# Run SchemaSpy
#######################################
run_schemaspy() {
    log "INFO" "Running SchemaSpy..."

    mkdir -p "${OUTPUT_DIR}"

    # Determine SchemaSpy database type
    # Note: SchemaSpy 6.2.4+ has built-in Redshift type, no custom properties needed
    local schemaspy_type="${DB_TYPE}"

    # Set connection properties based on database type and SSL mode
    local conn_props=""
    case "${DB_TYPE}" in
        pgsql | pgsql11)
            conn_props="sslmode\\=${SSL_MODE}"
            ;;
        redshift)
            if [ "${SSL_MODE}" == "disable" ]; then
                conn_props="ssl\\=false"
            else
                conn_props="ssl\\=true"
            fi
            ;;
        mysql)
            if [ "${SSL_MODE}" == "disable" ]; then
                conn_props="useSSL\\=false"
            else
                conn_props="useSSL\\=true"
            fi
            ;;
    esac

    local schemaspy_log="${OUTPUT_DIR}/schemaspy.log"

    # Build SchemaSpy command with JVM memory optimization
    # -Xmx: Maximum heap size (2GB for large databases)
    # -Xms: Initial heap size (512MB for faster startup)
    local java_cmd=(
        java
        -Xmx4g
        -Xms512m
        -jar "${SCHEMASPY_JAR}"
        -t "${schemaspy_type}"
        -u "${DB_USER}"
        -p "${DB_PASSWORD}"
    )

    # Add schema parameter: -s for specific schema, -all for all schemas
    if [ -n "${SCHEMA_NAME}" ]; then
        java_cmd+=(-s "${SCHEMA_NAME}")
        log "INFO" "Documenting specific schema: ${SCHEMA_NAME}"
    else
        java_cmd+=(-all)
        log "INFO" "Documenting all schemas in database (-all)"
    fi

    java_cmd+=(-o "${OUTPUT_DIR}")

    # Add database threads parameter to control concurrent connections
    if [ "${DB_TYPE}" == "redshift" ]; then
        # Redshift can be sensitive to too many connections; use 1 thread by default
        # https://docs.aws.amazon.com/redshift/latest/mgmt/jdbc20-download-driver.html
        java_cmd+=(-dbthreads "1")
        log "INFO" "Using 1 database threads for Redshift parallel processing"
    else
        java_cmd+=(-dbthreads "${DB_THREADS}")
        log "INFO" "Using ${DB_THREADS} database threads for parallel processing"
    fi

    # Consolidated handling for JDBC driver classpath, host, DB and connection properties
    # Combine driver (-dp) and connection (-host/-db/-connprops) setup per DB type to avoid duplicate case blocks
    case "${DB_TYPE}" in
        redshift)
            # Redshift JDBC driver requires AWS SDK dependencies
            local aws_sdk_jar="/workspace/tmp/aws-java-sdk-core.jar"
            if [ ! -f "${aws_sdk_jar}" ]; then
                log "WARN" "AWS SDK JAR not found, downloading..."
                curl -sSL -o "${aws_sdk_jar}" "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.12.529/aws-java-sdk-core-1.12.529.jar"
            fi
            # Add Redshift driver + AWS SDK to classpath
            java_cmd+=(-dp "${JDBC_DRIVER}:${aws_sdk_jar}")

            # Host and DB URL (add ssl flag for non-disabled SSL modes)
            java_cmd+=(-host "localhost:${LOCAL_PORT}")
            if [ "${SSL_MODE}" != "disable" ]; then
                java_cmd+=(-db "${DB_NAME}?ssl=true")
            else
                java_cmd+=(-db "${DB_NAME}?ssl=false")
            fi

            log "INFO" "Using built-in Redshift type (SchemaSpy 6.2.4+)"
            ;;

        pgsql | pgsql11)
            # PostgreSQL driver on classpath
            java_cmd+=(-dp "${JDBC_DRIVER}")

            # Host and DB URL (add ssl flag for non-disabled SSL modes)
            java_cmd+=(-host "localhost:${LOCAL_PORT}")
            if [ "${SSL_MODE}" != "disable" ]; then
                java_cmd+=(-db "${DB_NAME}?ssl=true")
            else
                java_cmd+=(-db "${DB_NAME}?ssl=false")
            fi

            # Optional connection properties (sslmode etc.)
            if [ -n "${conn_props}" ]; then
                java_cmd+=(-connprops "${conn_props}")
            fi
            ;;

        mysql)
            # MySQL driver on classpath
            java_cmd+=(-dp "${JDBC_DRIVER}")

            # Host and DB name
            java_cmd+=(-host "localhost:${LOCAL_PORT}")
            java_cmd+=(-db "${DB_NAME}")
            if [ -n "${conn_props}" ]; then
                java_cmd+=(-connprops "${conn_props}")
            fi
            ;;

        *)
            # Default handling for unknown DB types: place JDBC driver on classpath and basic connection
            java_cmd+=(-dp "${JDBC_DRIVER}")
            java_cmd+=(-host "localhost:${LOCAL_PORT}")
            java_cmd+=(-db "${DB_NAME}")
            if [ -n "${conn_props}" ]; then
                java_cmd+=(-connprops "${conn_props}")
            fi
            ;;
    esac

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would execute:"
        log "INFO" "  ${java_cmd[*]}"
        return 0
    fi

    # Execute SchemaSpy
    "${java_cmd[@]}" 2>&1 | tee "${schemaspy_log}"

    local exit_code=${PIPESTATUS[0]}
    if [ "${exit_code}" -ne 0 ]; then
        error_exit "SchemaSpy execution failed with exit code ${exit_code}. Check log: ${schemaspy_log}"
    fi

    log "INFO" "SchemaSpy execution completed successfully"
}

#######################################
# Verify generated documentation
#######################################
verify_output() {
    log "INFO" "Verifying generated documentation..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Skipping verification"
        return 0
    fi

    if [ ! -f "${OUTPUT_DIR}/index.html" ]; then
        error_exit "index.html not found in ${OUTPUT_DIR}"
    fi

    log "INFO" "SUCCESS! HTML documentation generated"
    log "INFO" ""
    log "INFO" "Generated files (top 20):"
    find "${OUTPUT_DIR}/" -maxdepth 1 -type f -exec ls -lh {} \; | head -20
    log "INFO" ""

    local file_count
    local total_size
    file_count=$(find "${OUTPUT_DIR}" -type f | wc -l)
    total_size=$(du -sh "${OUTPUT_DIR}" | cut -f1)

    log "INFO" "Statistics:"
    log "INFO" "  Total files: ${file_count}"
    log "INFO" "  Total size: ${total_size}"
    log "INFO" ""
    log "INFO" "View documentation:"
    log "INFO" "  file://${OUTPUT_DIR}/index.html"
}

#######################################
# Main execution function
#######################################
main() {
    echo_section "SchemaSpy Database Documentation Generator"

    # Parse command line arguments
    parse_arguments "$@"

    # Validate parameters
    validate_parameters

    # Validate dependencies
    validate_dependencies "aws" "jq" "java" "curl"

    # Register cleanup function
    trap cleanup EXIT INT TERM

    # Execute workflow
    if [ -z "${BASTION_ID}" ]; then
        detect_bastion
    else
        log "INFO" "Using specified Bastion: ${BASTION_ID}"
    fi

    verify_bastion
    retrieve_credentials
    start_port_forwarding
    download_dependencies
    run_schemaspy
    verify_output

    echo_section "Documentation generation completed successfully!"
    log "INFO" "Note: SSM session cleanup is handled automatically by trap"
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
