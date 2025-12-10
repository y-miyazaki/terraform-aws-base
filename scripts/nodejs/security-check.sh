#!/bin/bash
#######################################
# Description: Node.js security check script for package vulnerabilities and integrity
# Usage: ./security-check.sh
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
# main: Main security check function
#
# Description:
#   Performs comprehensive Node.js security checks including package vulnerabilities and integrity
#
# Arguments:
#   None
#
# Returns:
#   None (exits with appropriate status code)
#
# Usage:
#   main
#
#######################################
function main {
    log "INFO" "🔍 Starting Node.js security checks..."

    # Change to project root
    if ! cd /workspace; then
        error_exit "Failed to change to project root directory"
    fi

    # Check if package.json exists
    if [ ! -f "package.json" ]; then
        error_exit "❌ package.json not found!"
    fi

    # Check if package-lock.json exists
    if [ ! -f "package-lock.json" ]; then
        log "WARN" "❌ package-lock.json not found!"
        log "WARN" "This could indicate security risk - packages may install different versions"
    else
        log "INFO" "✅ package-lock.json found"
    fi

    # Check if package.json and package-lock.json are in sync
    log "INFO" "📦 Verifying package.json and package-lock.json sync..."
    if ! execute_command "npm ci --dry-run"; then
        log "WARN" "⚠️  package.json and package-lock.json may be out of sync"
    else
        log "INFO" "✅ Package files are in sync"
    fi

    # Check for known vulnerabilities
    log "INFO" "🛡️  Running security audit..."
    if ! execute_command "npm audit --audit-level moderate"; then
        log "WARN" "⚠️  Security vulnerabilities found - review npm audit output"
    else
        log "INFO" "✅ No security vulnerabilities found"
    fi

    # Check for outdated packages
    log "INFO" "📅 Checking for outdated packages..."
    if ! execute_command "npm outdated" 2> /dev/null; then
        log "INFO" "✅ All packages are up to date"
    else
        log "INFO" "ℹ️  Some packages have updates available (see above)"
    fi

    # Check .npmrc configuration
    log "INFO" "⚙️  Checking npm configuration..."
    if [ -f ".npmrc" ]; then
        if grep -q "ignore-scripts=true" .npmrc; then
            log "INFO" "✅ Script execution protection enabled"
        else
            log "WARN" "⚠️  Script execution protection not found in .npmrc"
        fi

        if grep -q "strict-ssl=true" .npmrc; then
            log "INFO" "✅ Strict SSL enabled"
        else
            log "WARN" "⚠️  Strict SSL not enabled in .npmrc"
        fi
    else
        log "WARN" "⚠️  .npmrc not found - consider adding security configurations"
    fi

    log "INFO" "🎉 Node.js security checks completed!"
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
