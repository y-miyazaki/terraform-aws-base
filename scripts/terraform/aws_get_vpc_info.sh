#!/bin/bash
#######################################
# Description: Get VPC-related resource information for a specified VPC
# Usage: ./aws_get_vpc_info.sh <VPC_ID>
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
VPC_ID=""
REGION="${AWS_DEFAULT_REGION:-ap-northeast-1}"

#######################################
# show_usage: Display script usage information
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
#   Exits with status 0 after displaying help
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "Description: Get VPC-related resource information for a specified VPC"
    echo ""
    echo "Options:"
    echo "  -h, --help    Display this help message"
    echo ""
    echo "Arguments:"
    echo "  VPC_ID        VPC ID to query resources for"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") vpc-1234567890abcdef0"
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and validates required VPC ID
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   VPC_ID - Set to the provided VPC ID
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
                if [[ -z "${VPC_ID:-}" ]]; then
                    VPC_ID="$1"
                else
                    error_exit "Unexpected argument: $1"
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "${VPC_ID:-}" ]]; then
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
# Arguments:
#   None
#
# Global Variables:
#   VPC_ID - VPC ID to check
#   REGION - AWS region to query
#
# Returns:
#   Outputs EC2 instance information
#
# Usage:
#   check_ec2_instances
#
#######################################
function check_ec2_instances {
    echo_section "EC2 Instances"
    if aws ec2 describe-instances --region "$REGION" --filters 'Name=vpc-id,Values='"$VPC_ID" | grep InstanceId; then
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
# Arguments:
#   None
#
# Global Variables:
#   VPC_ID - VPC ID to check
#   REGION - AWS region to query
#
# Returns:
#   Outputs NAT gateway information
#
# Usage:
#   check_nat_gateways
#
#######################################
function check_nat_gateways {
    echo_section "NAT Gateways"
    if aws ec2 describe-nat-gateways --region "$REGION" --filter 'Name=vpc-id,Values='"$VPC_ID" | grep NatGatewayId; then
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
# Arguments:
#   None
#
# Global Variables:
#   VPC_ID - VPC ID to check
#   REGION - AWS region to query
#
# Returns:
#   Outputs network interface information
#
# Usage:
#   check_network_interfaces
#
#######################################
function check_network_interfaces {
    echo_section "Network Interfaces"
    if aws ec2 describe-network-interfaces --region "$REGION" --filters 'Name=vpc-id,Values='"$VPC_ID" | grep NetworkInterfaceId; then
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
# Arguments:
#   None
#
# Global Variables:
#   VPC_ID - VPC ID to check
#   REGION - AWS region to query
#
# Returns:
#   Outputs VPN gateway information
#
# Usage:
#   check_vpn_gateways
#
#######################################
function check_vpn_gateways {
    echo_section "VPN Gateways"
    if aws ec2 describe-vpn-gateways --region "$REGION" --filters 'Name=attachment.vpc-id,Values='"$VPC_ID" | grep VpnGatewayId; then
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
# Arguments:
#   None
#
# Global Variables:
#   VPC_ID - VPC ID to check
#   REGION - AWS region to query
#
# Returns:
#   Outputs VPC peering connection information
#
# Usage:
#   check_vpc_peering
#
#######################################
function check_vpc_peering {
    echo_section "VPC Peering Connections"
    if aws ec2 describe-vpc-peering-connections --region "$REGION" --filters 'Name=requester-vpc-info.vpc-id,Values='"$VPC_ID" | grep VpcPeeringConnectionId; then
        log "INFO" "VPC peering connections found"
    else
        log "INFO" "No VPC peering connections found"
    fi
}

#######################################
# main: Script entry point
#
# Description:
#   Main function to execute the script logic for retrieving VPC resource information
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   VPC_ID - VPC ID to query
#   REGION - AWS region to query
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
    if ! check_aws_credentials; then
        error_exit "AWS credentials are not set or invalid."
    fi

    # Log script start
    echo_section "VPC Resource Information"
    log "INFO" "Target VPC: $VPC_ID"
    log "INFO" "Target region: $REGION"

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
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
