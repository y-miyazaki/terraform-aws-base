#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  name_prefix = var.name_prefix == "" ? "" : "${trimsuffix(var.name_prefix, "-")}-"
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "approved-amis-by-id" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}approved-amis-by-id"
#   description = "Checks whether running instances are using specified AMIs."
#   source {
#     owner             = "AWS"
#     source_identifier = "APPROVED_AMIS_BY_ID"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "approved-amis-by-tag" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}approved-amis-by-tag"
#   description = "Checks whether running instances are using specified AMIs."
#   source {
#     owner             = "AWS"
#     source_identifier = "APPROVED_AMIS_BY_TAG"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "desired-instance-tenancy" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}desired-instance-tenancy"
#   description = "Checks instances for specified tenancy."
#   source {
#     owner             = "AWS"
#     source_identifier = "DESIRED_INSTANCE_TENANCY"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "desired-instance-type" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}desired-instance-type"
#   description = "Checks whether your EC2 instances are of the specified instance types."
#   source {
#     owner             = "AWS"
#     source_identifier = "DESIRED_INSTANCE_TYPE"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "ebs-optimized-instance" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}ebs-optimized-instance"
  description = "Checks whether EBS optimization is enabled for your EC2 instances that can be EBS-optimized."
  source {
    owner             = "AWS"
    source_identifier = "EBS_OPTIMIZED_INSTANCE"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ebs-snapshot-public-restorable-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ebs-snapshot-public-restorable-check"
#   description = "Checks whether Amazon Elastic Block Store (Amazon EBS) snapshots are not publicly restorable. The rule is NON_COMPLIANT if one or more snapshots with RestorableByUserIds field are set to all, that is, Amazon EBS snapshots are public."
#   source {
#     owner             = "AWS"
#     source_identifier = "EBS_SNAPSHOT_PUBLIC_RESTORABLE_CHECK"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-ebs-encryption-by-default" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-ebs-encryption-by-default"
#   description = "Check that Amazon Elastic Block Store (EBS) encryption is enabled by default. The rule is NON_COMPLIANT if the encryption is not enabled."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_EBS_ENCRYPTION_BY_DEFAULT"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-imdsv2-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-imdsv2-check"
#   description = "Checks whether your Amazon Elastic Compute Cloud (Amazon EC2) instance metadata version is configured with Instance Metadata Service Version 2 (IMDSv2). The rule is NON_COMPLIANT if the HttpTokens is set to optional."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_IMDSV2_CHECK"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "ec2-instance-detailed-monitoring-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}ec2-instance-detailed-monitoring-enabled"
  description = "Checks whether detailed monitoring is enabled for EC2 instances."
  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_DETAILED_MONITORING_ENABLED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-instance-managed-by-ssm" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-instance-managed-by-ssm"
#   description = "Checks whether the Amazon EC2 instances in your account are managed by AWS Systems Manager."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_INSTANCE_MANAGED_BY_SSM"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-instance-no-public-ip" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-instance-no-public-ip"
#   description = "Checks whether Amazon Elastic Compute Cloud (Amazon EC2) instances have a public IP association. The rule is NON_COMPLIANT if the publicIp field is present in the Amazon EC2 instance configuration item. This rule applies only to IPv4."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_INSTANCE_NO_PUBLIC_IP"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "ec2-instance-profile-attached" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}ec2-instance-profile-attached"
  description = "Checks if an Amazon Elastic Compute Cloud (Amazon EC2) instance has an Identity and Access Management (IAM) profile attached to it. This rule is NON_COMPLIANT if no IAM profile is attached to the Amazon EC2 instance."
  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_PROFILE_ATTACHED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "ec2-instances-in-vpc" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}ec2-instances-in-vpc"
  description = "Checks whether your EC2 instances belong to a virtual private cloud (VPC)."
  source {
    owner             = "AWS"
    source_identifier = "INSTANCES_IN_VPC"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-managedinstance-applications-blacklisted" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-managedinstance-applications-blacklisted"
#   description = "Checks that none of the specified applications are installed on the instance. Optionally, specify the version. Newer versions will not be blacklisted. Optionally, specify the platform to apply the rule only to instances running that platform."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_MANAGEDINSTANCE_APPLICATIONS_BLACKLISTED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-managedinstance-applications-required" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-managedinstance-applications-required"
#   description = "Checks whether all of the specified applications are installed on the instance. Optionally, specify the minimum acceptable version. Optionally, specify the platform to apply the rule only to instances running that platform."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_MANAGEDINSTANCE_APPLICATIONS_REQUIRED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-managedinstance-association-compliance-status-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-managedinstance-association-compliance-status-check"
#   description = "Checks whether the compliance status of the AWS Systems Manager association compliance is COMPLIANT or NON_COMPLIANT after the association execution on the instance. The rule is compliant if the field status is COMPLIANT."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_MANAGEDINSTANCE_ASSOCIATION_COMPLIANCE_STATUS_CHECK"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-managedinstance-inventory-blacklisted" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-managedinstance-inventory-blacklisted"
#   description = "Checks whether instances managed by Amazon EC2 Systems Manager are configured to collect blacklisted inventory types."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_MANAGEDINSTANCE_INVENTORY_BLACKLISTED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-managedinstance-patch-compliance-status-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-managedinstance-patch-compliance-status-check"
#   description = "Checks whether the compliance status of the AWS Systems Manager patch compliance is COMPLIANT or NON_COMPLIANT after the patch installation on the instance. The rule is compliant if the field status is COMPLIANT."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_MANAGEDINSTANCE_PATCH_COMPLIANCE_STATUS_CHECK"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-managedinstance-platform-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-managedinstance-platform-check"
#   description = "Checks whether EC2 managed instances have the desired configurations."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_MANAGEDINSTANCE_PLATFORM_CHECK"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-security-group-attached-to-eni" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}ec2-security-group-attached-to-eni"
#   description = "Checks that non-default security groups are attached to Amazon Elastic Compute Cloud (EC2) instances or an elastic network interfaces (ENIs). The rule returns NON_COMPLIANT if the security group is not associated with an EC2 instance or an ENI."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_SECURITY_GROUP_ATTACHED_TO_ENI"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "ec2-stopped-instance" {
#   count = var.is_enabled ? 1 : 0
#   name  = "${local.name_prefix}ec2-stopped-instance"
#   input_parameters = jsonencode({
#     AllowedDays = "30"
#   })
#   description = "Checks whether there are instances stopped for more than the allowed number of days."
#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_STOPPED_INSTANCE"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "ec2-volume-inuse-check" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}ec2-volume-inuse-check"
  description = "Checks whether EBS volumes are attached to EC2 instances."
  source {
    owner             = "AWS"
    source_identifier = "EC2_VOLUME_INUSE_CHECK"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "eip-attached" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}eip-attached"
#   description = "Checks whether all EIP addresses allocated to a VPC are attached to EC2 instances or in-use ENIs."
#   source {
#     owner             = "AWS"
#     source_identifier = "EIP_ATTACHED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "encrypted-volumes" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}encrypted-volumes"
#   description = "Checks whether EBS volumes that are in an attached state are encrypted."
#   source {
#     owner             = "AWS"
#     source_identifier = "ENCRYPTED_VOLUMES"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "restricted-common-ports" {
  count            = var.is_enabled ? 1 : 0
  name             = "${local.name_prefix}restricted-common-ports"
  description      = "Checks whether security groups that are in use disallow unrestricted incoming TCP traffic to the specified ports."
  input_parameters = jsonencode(var.restricted_common_ports.input_parameters)
  source {
    owner             = "AWS"
    source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "restricted-ssh" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}restricted-ssh"
  description = "Checks whether security groups that are in use disallow unrestricted incoming SSH traffic."
  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Remediation Configuration.
#--------------------------------------------------------------
resource "aws_config_remediation_configuration" "restricted-ssh" {
  count            = var.is_enabled && var.is_disable_public_access_for_security_group ? 1 : 0
  config_rule_name = aws_config_config_rule.restricted-ssh[0].name
  target_type      = "SSM_DOCUMENT"
  # https://docs.aws.amazon.com/systems-manager-automation-runbooks/latest/userguide/automation-aws-disablepublicaccessforsecuritygroup.html
  target_id = "AWS-DisablePublicAccessForSecurityGroup"
  parameter {
    name         = "AutomationAssumeRole"
    static_value = var.ssm_automation_assume_role_arn
  }
  parameter {
    name           = "GroupId"
    resource_value = "RESOURCE_ID"
  }
  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60
}

#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "subnet-auto-assign-public-ip-disabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}subnet-auto-assign-public-ip-disabled"
#   description = "Checks if Amazon Virtual Private Cloud (Amazon VPC) subnets are assigned a public IP address. This rule is NON_COMPLIANT if Amazon VPC has subnets that are assigned a public IP address."
#   source {
#     owner             = "AWS"
#     source_identifier = "SUBNET_AUTO_ASSIGN_PUBLIC_IP_DISABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "vpc-flow-logs-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}vpc-flow-logs-enabled"
#   description = "Checks whether Amazon Virtual Private Cloud flow logs are found and enabled for Amazon VPC."
#   source {
#     owner             = "AWS"
#     source_identifier = "VPC_FLOW_LOGS_ENABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "vpc-vpn-2-tunnels-up" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}vpc-vpn-2-tunnels-up"
#   description = "Checks that both VPN tunnels provided by AWS Site-to-Site VPN are in UP status. The rule returns NON_COMPLIANT if one or both tunnels are in DOWN status."
#   source {
#     owner             = "AWS"
#     source_identifier = "VPC_VPN_2_TUNNELS_UP"
#   }
#   tags = local.tags
# }
