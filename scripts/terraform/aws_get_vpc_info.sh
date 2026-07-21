#!/bin/bash
#######################################
# Description: Get VPC-related resource information for a specified VPC
#
# Usage: ./aws_get_vpc_info.sh <VPC_ID>
#   options:
#     -h, --help    Display this help message
#   arguments:
#     VPC_ID        VPC ID to query resources for
#
# Output:
# - VPC resource information (EC2, NAT Gateways, ENIs, VPN, Peering) to stdout
#
# Design Rules:
# - Queries multiple AWS services for VPC-related resources
# - Validates VPC ID before querying
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# Global variables
#######################################
VPC_ID=""
AWS_REGION="${AWS_REGION:-}"

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Writes to stdout
#
# Returns:
#   None
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [options]

Description: Get VPC-related resource information for a specified VPC

Options:
  -h, --help    Display this help message

Arguments:
  VPC_ID        VPC ID to query resources for

Examples:
  $(basename "$0") vpc-1234567890abcdef0
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and validates required VPC ID
#
# Globals:
#   VPC_ID - Set to the provided VPC ID
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Outputs:
#   None
#
# Returns:
#   Exits with error if VPC ID is not provided or unknown arguments are given
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help)
                show_usage
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                # Process VPC ID
                if [[ -z ${VPC_ID:-} ]]; then
                    VPC_ID="$1"
                else
                    error_exit "Unexpected argument: $1"
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z ${VPC_ID:-} ]]; then
        echo "Error: VPC ID is required" >&2
        show_usage
    fi
}

#######################################
# check_ec2_instances: Check EC2 instances
#
# Description:
#   Checks for EC2 instances running in the specified VPC
#
# Globals:
#   VPC_ID - VPC ID to check
#   REGION - AWS region to query
#
# Arguments:
#   None
#
# Outputs:
#   EC2 instance information
#
# Returns:
#   0 on success
#
# Usage:
#   check_ec2_instances
#
#######################################
function check_ec2_instances {
    echo_section "EC2 Instances"
    if aws ec2 describe-instances --region "$AWS_REGION" --filters 'Name=vpc-id,Values='"$VPC_ID" | grep InstanceId; then
        log "INFO" "EC2 instances found"
    else
        log "INFO" "No EC2 instances found"
    fi
}

#######################################
# check_nat_gateways: Check NAT gateways
#
# Description:
#   Checks for NAT gateways in the specified VPC
#
# Globals:
#   VPC_ID - VPC ID to check
#   REGION - AWS region to query
#
# Arguments:
#   None
#
# Outputs:
#   NAT gateway information
#
# Returns:
#   0 on success
#
# Usage:
#   check_nat_gateways
#
#######################################
function check_nat_gateways {
    echo_section "NAT Gateways"
    if aws ec2 describe-nat-gateways --region "$AWS_REGION" --filter 'Name=vpc-id,Values='"$VPC_ID" | grep NatGatewayId; then
        log "INFO" "NAT gateways found"
    else
        log "INFO" "No NAT gateways found"
    fi
}

#######################################
# check_network_interfaces: Check network interfaces
#
# Description:
#   Checks for network interfaces in the specified VPC
#
# Globals:
#   VPC_ID - VPC ID to check
#   REGION - AWS region to query
#
# Arguments:
#   None
#
# Outputs:
#   network interface information
#
# Returns:
#   0 on success
#
# Usage:
#   check_network_interfaces
#
#######################################
function check_network_interfaces {
    echo_section "Network Interfaces"
    if aws ec2 describe-network-interfaces --region "$AWS_REGION" --filters 'Name=vpc-id,Values='"$VPC_ID" | grep NetworkInterfaceId; then
        log "INFO" "Network interfaces found"
    else
        log "INFO" "No network interfaces found"
    fi
}

#######################################
# check_vpn_gateways: Check VPN gateways
#
# Description:
#   Checks for VPN gateways attached to the specified VPC
#
# Globals:
#   VPC_ID - VPC ID to check
#   REGION - AWS region to query
#
# Arguments:
#   None
#
# Outputs:
#   VPN gateway information
#
# Returns:
#   0 on success
#
# Usage:
#   check_vpn_gateways
#
#######################################
function check_vpn_gateways {
    echo_section "VPN Gateways"
    if aws ec2 describe-vpn-gateways --region "$AWS_REGION" --filters 'Name=attachment.vpc-id,Values='"$VPC_ID" | grep VpnGatewayId; then
        log "INFO" "VPN gateways found"
    else
        log "INFO" "No VPN gateways found"
    fi
}

#######################################
# check_vpc_peering: Check VPC peering connections
#
# Description:
#   Checks for VPC peering connections associated with the specified VPC
#
# Globals:
#   VPC_ID - VPC ID to check
#   REGION - AWS region to query
#
# Arguments:
#   None
#
# Outputs:
#   VPC peering connection information
#
# Returns:
#   0 on success
#
# Usage:
#   check_vpc_peering
#
#######################################
function check_vpc_peering {
    echo_section "VPC Peering Connections"
    if aws ec2 describe-vpc-peering-connections --region "$AWS_REGION" --filters 'Name=requester-vpc-info.vpc-id,Values='"$VPC_ID" | grep VpcPeeringConnectionId; then
        log "INFO" "VPC peering connections found"
    else
        log "INFO" "No VPC peering connections found"
    fi
}

#######################################
# main: Main process
#
# Description:
#   Main function to execute the script logic for retrieving VPC resource information
#
# Globals:
#   VPC_ID - VPC ID to query
#   REGION - AWS region to query
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Outputs:
#   None
#
# Returns:
#   Exits with status 0 on success, non-zero on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Parse arguments
    parse_arguments "$@"

    # Validate required dependencies
    validate_dependencies "aws"

    # Check AWS credentials before any AWS CLI usage
    check_aws_credentials || error_exit "AWS credentials are not set or invalid."

    # Auto-detect AWS_REGION from AWS CLI if not provided
    AWS_REGION="${AWS_REGION:-$(get_aws_region)}"

    # Log script start
    echo_section "VPC Resource Information"
    log "INFO" "Target VPC: $VPC_ID"
    log "INFO" "Target region: $AWS_REGION"

    # Check all VPC-related resources
    check_vpc_peering
    check_nat_gateways
    check_ec2_instances
    check_vpn_gateways
    check_network_interfaces

    echo_section "Process completed successfully"
    log "INFO" "VPC resource information retrieval completed"
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
