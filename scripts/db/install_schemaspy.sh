#!/bin/bash
#######################################
# Description: Install SchemaSpy and its dependencies (Java, Graphviz, JDBC drivers)
# Usage: ./install_schemaspy.sh [options]
#   options:
#     -h, --help           Display this help message
#     -v, --verbose        Enable verbose output
#     -d, --dry-run        Show what would be done without executing
#     -f, --force          Force reinstall even if already installed
#     -t, --db-type        Database type to install JDBC driver for (pgsql, mysql, oracle, redshift, all)
#     --skip-java          Skip Java installation check/install
#     --skip-graphviz      Skip Graphviz installation check/install
#     --skip-schemaspy     Skip SchemaSpy download
#     --skip-jdbc          Skip JDBC driver download
#     --schemaspy-version  SchemaSpy version to install (default: 6.2.4)
#     --install-dir        Installation directory (default: /workspace/tmp)
#
# Output:
# - Installs Java (OpenJDK) if not present
# - Installs Graphviz if not present
# - Downloads SchemaSpy JAR to installation directory
# - Downloads JDBC drivers to installation directory
# - Validates all installations
#
# Design Rules:
# - Checks existing installations before attempting install
# - Supports multiple database types for JDBC drivers
# - Uses system package manager for Java and Graphviz
# - Downloads latest stable versions from official sources
# - Validates installations after completion
# - Idempotent - safe to run multiple times
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
FORCE_INSTALL=false
DB_TYPE="all"
SKIP_JAVA=false
SKIP_GRAPHVIZ=false
SKIP_SCHEMASPY=false
SKIP_JDBC=false
SCHEMASPY_VERSION="7.0.2"
INSTALL_DIR="/workspace/tmp"

# JDBC driver versions
JDBC_VERSION_POSTGRESQL="42.7.5"
JDBC_VERSION_MYSQL="8.0.33"
JDBC_VERSION_REDSHIFT="2.1.0.32"

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

Description: Install SchemaSpy and its dependencies (Java, Graphviz, JDBC drivers).

Optional Options:
  -h, --help           Display this help message
  -v, --verbose        Enable verbose output
  -d, --dry-run        Show what would be done without executing
  -f, --force          Force reinstall even if already installed
  -t, --db-type        Database type for JDBC driver (pgsql, mysql, oracle, redshift, all) (default: all)
  --skip-java          Skip Java installation check/install
  --skip-graphviz      Skip Graphviz installation check/install
  --skip-schemaspy     Skip SchemaSpy download
  --skip-jdbc          Skip JDBC driver download
  --schemaspy-version  SchemaSpy version (default: 6.2.4)
  --install-dir        Installation directory (default: /workspace/tmp)

Examples:
  $(basename "$0")                          # Install everything with defaults
  $(basename "$0") -v                       # Verbose mode
  $(basename "$0") -t pgsql                 # Install only PostgreSQL JDBC driver
  $(basename "$0") -t redshift              # Install only Redshift JDBC driver
  $(basename "$0") --skip-java -t mysql     # Skip Java, install MySQL driver only
  $(basename "$0") -f                       # Force reinstall all components

Components Installed:
  - Java (OpenJDK 17): Required for running SchemaSpy
  - Graphviz: Required for generating ER diagrams
  - SchemaSpy JAR: Schema analysis and documentation tool
  - JDBC Drivers: Database connectivity (PostgreSQL, MySQL, Redshift)

Installation Locations:
  - Java: System package manager (/usr/lib/jvm/)
  - Graphviz: System package manager (/usr/bin/)
  - SchemaSpy: ${INSTALL_DIR}/schemaspy-{version}.jar
  - JDBC Drivers: ${INSTALL_DIR}/{db_type}-jdbc.jar

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
#   FORCE_INSTALL - Force reinstallation of components
#   DB_TYPE - Database type to install JDBC drivers for
#   SKIP_JAVA - Skip Java installation
#   SKIP_GRAPHVIZ - Skip Graphviz installation
#   SKIP_SCHEMASPY - Skip SchemaSpy download
#   SKIP_JDBC - Skip JDBC driver download
#   SCHEMASPY_VERSION - SchemaSpy version to download
#   INSTALL_DIR - Installation directory
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
            -f | --force)
                FORCE_INSTALL=true
                shift
                ;;
            -t | --db-type)
                DB_TYPE="$2"
                shift 2
                ;;
            --skip-java)
                SKIP_JAVA=true
                shift
                ;;
            --skip-graphviz)
                SKIP_GRAPHVIZ=true
                shift
                ;;
            --skip-schemaspy)
                SKIP_SCHEMASPY=true
                shift
                ;;
            --skip-jdbc)
                SKIP_JDBC=true
                shift
                ;;
            --schemaspy-version)
                SCHEMASPY_VERSION="$2"
                shift 2
                ;;
            --install-dir)
                INSTALL_DIR="$2"
                shift 2
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
# validate_parameters: Validate parameters
#
# Description:
#   Validates parameters and sets default values
#
# Arguments:
#   None
#
# Global Variables:
#   DB_TYPE - Database type
#   INSTALL_DIR - Installation directory
#   FORCE_INSTALL - Force reinstallation flag
#   SKIP_JAVA - Skip Java installation flag
#   SKIP_GRAPHVIZ - Skip Graphviz installation flag
#   SKIP_SCHEMASPY - Skip SchemaSpy download flag
#   SKIP_JDBC - Skip JDBC driver download flag
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

    # Validate database type
    case "${DB_TYPE}" in
        pgsql | mysql | oracle | redshift | all) ;;
        *)
            error_exit "Invalid database type: ${DB_TYPE}. Must be: pgsql, mysql, oracle, redshift, or all"
            ;;
    esac

    # Create installation directory if it doesn't exist
    if [ ! -d "${INSTALL_DIR}" ]; then
        log "INFO" "Creating installation directory: ${INSTALL_DIR}"
        mkdir -p "${INSTALL_DIR}"
    fi

    log "DEBUG" "Configuration:"
    log "DEBUG" "  Database Type: ${DB_TYPE}"
    log "DEBUG" "  SchemaSpy Version: ${SCHEMASPY_VERSION}"
    log "DEBUG" "  Installation Directory: ${INSTALL_DIR}"
    log "DEBUG" "  Force Install: ${FORCE_INSTALL}"
    log "DEBUG" "  Skip Java: ${SKIP_JAVA}"
    log "DEBUG" "  Skip Graphviz: ${SKIP_GRAPHVIZ}"
    log "DEBUG" "  Skip SchemaSpy: ${SKIP_SCHEMASPY}"
    log "DEBUG" "  Skip JDBC: ${SKIP_JDBC}"
}

#######################################
# Check if Java is installed
#######################################
check_java() {
    log "INFO" "Checking Java installation..."

    if command -v java &> /dev/null; then
        local java_version
        java_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
        log "INFO" "Java is already installed: ${java_version}"

        if [ "${FORCE_INSTALL}" = false ]; then
            return 0
        else
            log "WARN" "Force install enabled - will reinstall Java"
        fi
    else
        log "INFO" "Java is not installed"
    fi

    return 1
}

#######################################
# Install Java
#######################################
install_java() {
    if [ "${SKIP_JAVA}" = true ]; then
        log "INFO" "Skipping Java installation (--skip-java specified)"
        return 0
    fi

    if check_java && [ "${FORCE_INSTALL}" = false ]; then
        return 0
    fi

    log "INFO" "Installing Java (OpenJDK)..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would install Java"
        return 0
    fi

    # Detect package manager and install
    if command -v apt-get &> /dev/null; then
        log "INFO" "Using apt-get to install Java..."
        sudo apt-get update -qq

        # Try several candidate packages to handle different distro images
        local candidates=(openjdk-17-jdk openjdk-17-jdk-headless default-jdk openjdk-11-jdk-headless)
        local installed=false
        for pkg in "${candidates[@]}"; do
            log "DEBUG" "Attempting to install Java package: ${pkg}"
            if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${pkg}"; then
                log "INFO" "Installed Java package: ${pkg}"
                installed=true
                break
            else
                log "WARN" "Package ${pkg} not available or failed to install, trying next candidate..."
            fi
        done

        if [ "${installed}" = false ]; then
            error_exit "Failed to install any Java package via apt-get. Please install Java manually (e.g. openjdk) and re-run the script."
        fi
    elif command -v yum &> /dev/null; then
        log "INFO" "Using yum to install Java..."
        sudo yum install -y java-17-openjdk-devel
    elif command -v dnf &> /dev/null; then
        log "INFO" "Using dnf to install Java..."
        sudo dnf install -y java-17-openjdk-devel
    else
        error_exit "No supported package manager found (apt-get, yum, dnf)"
    fi

    # Verify installation
    if command -v java &> /dev/null; then
        local java_version
        java_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
        log "INFO" "Java installed successfully: ${java_version}"
    else
        error_exit "Java installation failed"
    fi
}

#######################################
# Check if Graphviz is installed
#######################################
check_graphviz() {
    log "INFO" "Checking Graphviz installation..."

    if command -v dot &> /dev/null; then
        local graphviz_version
        graphviz_version=$(dot -V 2>&1 | awk '{print $5}')
        log "INFO" "Graphviz is already installed: ${graphviz_version}"

        if [ "${FORCE_INSTALL}" = false ]; then
            return 0
        else
            log "WARN" "Force install enabled - will reinstall Graphviz"
        fi
    else
        log "INFO" "Graphviz is not installed"
    fi

    return 1
}

#######################################
# Install Graphviz
#######################################
install_graphviz() {
    if [ "${SKIP_GRAPHVIZ}" = true ]; then
        log "INFO" "Skipping Graphviz installation (--skip-graphviz specified)"
        return 0
    fi

    if check_graphviz && [ "${FORCE_INSTALL}" = false ]; then
        return 0
    fi

    log "INFO" "Installing Graphviz..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would install Graphviz"
        return 0
    fi

    # Detect package manager and install
    if command -v apt-get &> /dev/null; then
        log "INFO" "Using apt-get to install Graphviz..."
        sudo apt-get update -qq
        sudo apt-get install -y graphviz
    elif command -v yum &> /dev/null; then
        log "INFO" "Using yum to install Graphviz..."
        sudo yum install -y graphviz
    elif command -v dnf &> /dev/null; then
        log "INFO" "Using dnf to install Graphviz..."
        sudo dnf install -y graphviz
    else
        error_exit "No supported package manager found (apt-get, yum, dnf)"
    fi

    # Verify installation
    if command -v dot &> /dev/null; then
        local graphviz_version
        graphviz_version=$(dot -V 2>&1 | awk '{print $5}')
        log "INFO" "Graphviz installed successfully: ${graphviz_version}"
    else
        error_exit "Graphviz installation failed"
    fi
}

#######################################
# Download SchemaSpy
#######################################
download_schemaspy() {
    if [ "${SKIP_SCHEMASPY}" = true ]; then
        log "INFO" "Skipping SchemaSpy download (--skip-schemaspy specified)"
        return 0
    fi

    log "INFO" "Checking SchemaSpy..."

    local schemaspy_jar="${INSTALL_DIR}/schemaspy.jar"

    if [ -f "${schemaspy_jar}" ] && [ "${FORCE_INSTALL}" = false ]; then
        log "INFO" "SchemaSpy is already downloaded: ${schemaspy_jar}"
        return 0
    fi

    log "INFO" "Downloading SchemaSpy ${SCHEMASPY_VERSION}..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would download SchemaSpy to ${schemaspy_jar}"
        return 0
    fi

    local download_url="https://github.com/schemaspy/schemaspy/releases/download/v${SCHEMASPY_VERSION}/schemaspy-app.jar"

    curl -fsSL "${download_url}" -o "${schemaspy_jar}"

    # Verify download
    if [ -f "${schemaspy_jar}" ]; then
        local file_size
        file_size=$(du -h "${schemaspy_jar}" | cut -f1)
        log "INFO" "SchemaSpy downloaded successfully: ${file_size}"
    else
        error_exit "SchemaSpy download failed"
    fi
}

#######################################
# Download JDBC driver for PostgreSQL
#######################################
download_postgresql_jdbc() {
    log "INFO" "Checking PostgreSQL JDBC driver..."

    local jdbc_jar="${INSTALL_DIR}/pgsql-jdbc.jar"

    if [ -f "${jdbc_jar}" ] && [ "${FORCE_INSTALL}" = false ]; then
        log "INFO" "PostgreSQL JDBC driver is already downloaded: ${jdbc_jar}"
        return 0
    fi

    log "INFO" "Downloading PostgreSQL JDBC driver ${JDBC_VERSION_POSTGRESQL}..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would download PostgreSQL JDBC driver to ${jdbc_jar}"
        return 0
    fi

    local download_url="https://jdbc.postgresql.org/download/postgresql-${JDBC_VERSION_POSTGRESQL}.jar"

    curl -fsSL "${download_url}" -o "${jdbc_jar}"

    # Verify download
    if [ -f "${jdbc_jar}" ]; then
        local file_size
        file_size=$(du -h "${jdbc_jar}" | cut -f1)
        ln -s "${jdbc_jar}" "${INSTALL_DIR}/postgresql-jdbc.jar"
        ln -s "${jdbc_jar}" "${INSTALL_DIR}/pgsql11-jdbc.jar"
        log "INFO" "PostgreSQL JDBC driver downloaded successfully: ${file_size}"
    else
        error_exit "PostgreSQL JDBC driver download failed"
    fi
}

#######################################
# Download JDBC driver for MySQL
#######################################
download_mysql_jdbc() {
    log "INFO" "Checking MySQL JDBC driver..."

    local jdbc_jar="${INSTALL_DIR}/mysql-jdbc.jar"

    if [ -f "${jdbc_jar}" ] && [ "${FORCE_INSTALL}" = false ]; then
        log "INFO" "MySQL JDBC driver is already downloaded: ${jdbc_jar}"
        return 0
    fi

    log "INFO" "Downloading MySQL JDBC driver ${JDBC_VERSION_MYSQL}..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would download MySQL JDBC driver to ${jdbc_jar}"
        return 0
    fi

    local download_url="https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${JDBC_VERSION_MYSQL}/mysql-connector-j-${JDBC_VERSION_MYSQL}.jar"

    curl -fsSL "${download_url}" -o "${jdbc_jar}"

    # Verify download
    if [ -f "${jdbc_jar}" ]; then
        local file_size
        file_size=$(du -h "${jdbc_jar}" | cut -f1)
        log "INFO" "MySQL JDBC driver downloaded successfully: ${file_size}"
    else
        error_exit "MySQL JDBC driver download failed"
    fi
}

#######################################
# Download JDBC driver for Redshift
#######################################
download_redshift_jdbc() {
    log "INFO" "Checking Redshift JDBC driver..."

    local jdbc_jar="${INSTALL_DIR}/redshift-jdbc.jar"

    if [ -f "${jdbc_jar}" ] && [ "${FORCE_INSTALL}" = false ]; then
        log "INFO" "Redshift JDBC driver is already downloaded: ${jdbc_jar}"
        return 0
    fi

    log "INFO" "Downloading Redshift JDBC driver ${JDBC_VERSION_REDSHIFT}..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Would download Redshift JDBC driver to ${jdbc_jar}"
        return 0
    fi

    local download_url="https://s3.amazonaws.com/redshift-downloads/drivers/jdbc/${JDBC_VERSION_REDSHIFT}/redshift-jdbc42-${JDBC_VERSION_REDSHIFT}.jar"

    curl -fsSL "${download_url}" -o "${jdbc_jar}"

    # Verify download
    if [ -f "${jdbc_jar}" ]; then
        local file_size
        file_size=$(du -h "${jdbc_jar}" | cut -f1)
        log "INFO" "Redshift JDBC driver downloaded successfully: ${file_size}"
    else
        error_exit "Redshift JDBC driver download failed"
    fi
}

#######################################
# Download JDBC drivers
#######################################
download_jdbc_drivers() {
    if [ "${SKIP_JDBC}" = true ]; then
        log "INFO" "Skipping JDBC driver download (--skip-jdbc specified)"
        return 0
    fi

    log "INFO" "Downloading JDBC drivers for: ${DB_TYPE}"

    case "${DB_TYPE}" in
        pgsql)
            download_postgresql_jdbc
            ;;
        mysql)
            download_mysql_jdbc
            ;;
        redshift)
            download_redshift_jdbc
            ;;
        oracle)
            log "WARN" "Oracle JDBC driver must be manually downloaded due to license restrictions"
            log "INFO" "Download from: https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html"
            log "INFO" "Place driver in: ${INSTALL_DIR}/oracle-jdbc.jar"
            ;;
        all)
            download_postgresql_jdbc
            download_mysql_jdbc
            download_redshift_jdbc
            log "WARN" "Oracle JDBC driver must be manually downloaded (see above)"
            ;;
    esac
}

#######################################
# Verify installations
#######################################
verify_installations() {
    log "INFO" "Verifying installations..."

    if [ "${DRY_RUN}" = true ]; then
        log "INFO" "DRY RUN - Skipping verification"
        return 0
    fi

    local all_ok=true

    # Verify Java
    if [ "${SKIP_JAVA}" = false ]; then
        if command -v java &> /dev/null; then
            log "INFO" "✅ Java: OK"
        else
            log "ERROR" "❌ Java: NOT FOUND"
            all_ok=false
        fi
    fi

    # Verify Graphviz
    if [ "${SKIP_GRAPHVIZ}" = false ]; then
        if command -v dot &> /dev/null; then
            log "INFO" "✅ Graphviz: OK"
        else
            log "ERROR" "❌ Graphviz: NOT FOUND"
            all_ok=false
        fi
    fi

    # Verify SchemaSpy
    if [ "${SKIP_SCHEMASPY}" = false ]; then
        local schemaspy_jar="${INSTALL_DIR}/schemaspy-${SCHEMASPY_VERSION}.jar"
        if [ -f "${schemaspy_jar}" ]; then
            log "INFO" "✅ SchemaSpy: OK (${schemaspy_jar})"
        else
            log "ERROR" "❌ SchemaSpy: NOT FOUND"
            all_ok=false
        fi
    fi

    # Verify JDBC drivers
    if [ "${SKIP_JDBC}" = false ]; then
        case "${DB_TYPE}" in
            pgsql)
                if [ -f "${INSTALL_DIR}/pgsql-jdbc.jar" ]; then
                    log "INFO" "✅ PostgreSQL JDBC: OK"
                else
                    log "ERROR" "❌ PostgreSQL JDBC: NOT FOUND"
                    all_ok=false
                fi
                ;;
            mysql)
                if [ -f "${INSTALL_DIR}/mysql-jdbc.jar" ]; then
                    log "INFO" "✅ MySQL JDBC: OK"
                else
                    log "ERROR" "❌ MySQL JDBC: NOT FOUND"
                    all_ok=false
                fi
                ;;
            redshift)
                if [ -f "${INSTALL_DIR}/redshift-jdbc.jar" ]; then
                    log "INFO" "✅ Redshift JDBC: OK"
                else
                    log "ERROR" "❌ Redshift JDBC: NOT FOUND"
                    all_ok=false
                fi
                ;;
            all)
                if [ -f "${INSTALL_DIR}/pgsql-jdbc.jar" ]; then
                    log "INFO" "✅ PostgreSQL JDBC: OK"
                else
                    log "ERROR" "❌ PostgreSQL JDBC: NOT FOUND"
                    all_ok=false
                fi
                if [ -f "${INSTALL_DIR}/mysql-jdbc.jar" ]; then
                    log "INFO" "✅ MySQL JDBC: OK"
                else
                    log "ERROR" "❌ MySQL JDBC: NOT FOUND"
                    all_ok=false
                fi
                if [ -f "${INSTALL_DIR}/redshift-jdbc.jar" ]; then
                    log "INFO" "✅ Redshift JDBC: OK"
                else
                    log "ERROR" "❌ Redshift JDBC: NOT FOUND"
                    all_ok=false
                fi
                ;;
        esac
    fi

    if [ "${all_ok}" = false ]; then
        error_exit "Some installations failed. Please check the errors above."
    fi
}

#######################################
# Display installation summary
#######################################
display_summary() {
    log "INFO" ""
    log "INFO" "========================================"
    log "INFO" "Installation Summary"
    log "INFO" "========================================"

    if [ "${SKIP_JAVA}" = false ]; then
        if command -v java &> /dev/null; then
            local java_version
            java_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
            log "INFO" "Java: ${java_version}"
        fi
    fi

    if [ "${SKIP_GRAPHVIZ}" = false ]; then
        if command -v dot &> /dev/null; then
            local graphviz_version
            graphviz_version=$(dot -V 2>&1 | awk '{print $5}')
            log "INFO" "Graphviz: ${graphviz_version}"
        fi
    fi

    if [ "${SKIP_SCHEMASPY}" = false ]; then
        log "INFO" "SchemaSpy: ${SCHEMASPY_VERSION}"
        log "INFO" "  Location: ${INSTALL_DIR}/schemaspy-${SCHEMASPY_VERSION}.jar"
    fi

    if [ "${SKIP_JDBC}" = false ]; then
        case "${DB_TYPE}" in
            pgsql)
                log "INFO" "PostgreSQL JDBC: ${JDBC_VERSION_POSTGRESQL}"
                log "INFO" "  Location: ${INSTALL_DIR}/pgsql-jdbc.jar"
                ;;
            mysql)
                log "INFO" "MySQL JDBC: ${JDBC_VERSION_MYSQL}"
                log "INFO" "  Location: ${INSTALL_DIR}/mysql-jdbc.jar"
                ;;
            redshift)
                log "INFO" "Redshift JDBC: ${JDBC_VERSION_REDSHIFT}"
                log "INFO" "  Location: ${INSTALL_DIR}/redshift-jdbc.jar"
                ;;
            all)
                log "INFO" "PostgreSQL JDBC: ${JDBC_VERSION_POSTGRESQL}"
                log "INFO" "  Location: ${INSTALL_DIR}/pgsql-jdbc.jar"
                log "INFO" "MySQL JDBC: ${JDBC_VERSION_MYSQL}"
                log "INFO" "  Location: ${INSTALL_DIR}/mysql-jdbc.jar"
                log "INFO" "Redshift JDBC: ${JDBC_VERSION_REDSHIFT}"
                log "INFO" "  Location: ${INSTALL_DIR}/redshift-jdbc.jar"
                ;;
        esac
    fi

    log "INFO" ""
    log "INFO" "Next steps:"
    log "INFO" "  Run: ./aws_schemaspy.sh -e <env> -i <identifier> -n <db_name>"
    log "INFO" ""
}

#######################################
# Main execution function
#######################################
main() {
    echo_section "SchemaSpy Installation Script"

    # Parse command line arguments
    parse_arguments "$@"

    # Validate parameters
    validate_parameters

    # Check for required commands
    validate_dependencies "curl"

    # Install components
    install_java
    install_graphviz
    download_schemaspy
    download_jdbc_drivers

    # Verify all installations
    verify_installations

    # Display summary
    display_summary

    echo_section "Installation completed successfully!"
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
