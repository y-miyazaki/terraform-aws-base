#!/bin/bash
# shellcheck disable=SC1091
#######################################
# Description: All-in-one library loader for shell scripts
# This file loads all individual libraries (common.sh, aws.sh, terraform.sh, validation.sh)
# to simplify library loading and prevent missing imports
#
# Usage: source "${SCRIPT_DIR}/../lib/all.sh"
#######################################

# Prevent multiple loading
if [[ "${_LIB_ALL_LOADED:-}" == "true" ]]; then
    return 0
fi
_LIB_ALL_LOADED=true

# Get current directory for library loading
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all individual libraries
# shellcheck source=./common.sh
source "${LIB_DIR}/common.sh"

# shellcheck source=./aws.sh
source "${LIB_DIR}/aws.sh"

# shellcheck source=./csv.sh
source "${LIB_DIR}/csv.sh"

# shellcheck source=./terraform.sh
source "${LIB_DIR}/terraform.sh"

# shellcheck source=./validation.sh
source "${LIB_DIR}/validation.sh"
