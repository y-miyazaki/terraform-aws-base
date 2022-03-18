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
resource "aws_config_config_rule" "aurora-mysql-backtracking-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}aurora-mysql-backtracking-enabled"
  description = "Checks if an Amazon Aurora MySQL cluster has backtracking enabled. This rule is NON_COMPLIANT if the Aurora cluster uses MySQL and it does not have backtracking enabled."
  source {
    owner             = "AWS"
    source_identifier = "AURORA_MYSQL_BACKTRACKING_ENABLED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "db-instance-backup-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}db-instance-backup-enabled"
  description = "Checks whether RDS DB instances have backups enabled."
  source {
    owner             = "AWS"
    source_identifier = "DB_INSTANCE_BACKUP_ENABLED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "rds-automatic-minor-version-upgrade-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}rds-automatic-minor-version-upgrade-enabled"
  description = "Checks if Amazon Relational Database Service (RDS) database instances are configured for automatic minor version upgrades. The rule is NON_COMPLIANT if the value of 'autoMinorVersionUpgrade' is false."
  source {
    owner             = "AWS"
    source_identifier = "RDS_AUTOMATIC_MINOR_VERSION_UPGRADE_ENABLED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "rds-cluster-deletion-protection-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}rds-cluster-deletion-protection-enabled"
#   description = "Checks if an Amazon Relational Database Service (Amazon RDS) cluster has deletion protection enabled. This rule is NON_COMPLIANT if an RDS cluster does not have deletion protection enabled."
#   source {
#     owner             = "AWS"
#     source_identifier = "RDS_CLUSTER_DELETION_PROTECTION_ENABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "rds-in-backup-plan" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}rds-in-backup-plan"
  description = "Checks whether Amazon RDS database is present in back plans of AWS Backup. The rule is NON_COMPLIANT if Amazon RDS databases are not included in any AWS Backup plan."
  source {
    owner             = "AWS"
    source_identifier = "RDS_IN_BACKUP_PLAN"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "rds-instance-deletion-protection-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}rds-instance-deletion-protection-enabled"
#   description = "Checks if an Amazon Relational Database Service (Amazon RDS) instance has deletion protection enabled. This rule is NON_COMPLIANT if an Amazon RDS instance does not have deletion protection enabled i.e deletionProtection is set to false."
#   source {
#     owner             = "AWS"
#     source_identifier = "RDS_INSTANCE_DELETION_PROTECTION_ENABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "rds-instance-public-access-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}rds-instance-public-access-check"
#   description = "Checks whether the Amazon Relational Database Service (RDS) instances are not publicly accessible. The rule is non-compliant if the publiclyAccessible field is true in the instance configuration item."
#   source {
#     owner             = "AWS"
#     source_identifier = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "rds-logging-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}rds-logging-enabled"
#   description = "Checks that respective logs of Amazon Relational Database Service (Amazon RDS) are enabled. The rule is NON_COMPLIANT if any log types are not enabled."
#   source {
#     owner             = "AWS"
#     source_identifier = "RDS_LOGGING_ENABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "rds-multi-az-support" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}rds-multi-az-support"
#   description = "Checks whether high availability is enabled for your RDS DB instances."
#   source {
#     owner             = "AWS"
#     source_identifier = "RDS_MULTI_AZ_SUPPORT"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "rds-snapshot-encrypted" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}rds-snapshot-encrypted"
#   description = "Checks whether Amazon Relational Database Service (Amazon RDS) DB snapshots are encrypted. The rule is NON_COMPLIANT, if the Amazon RDS DB snapshots are not encrypted."
#   source {
#     owner             = "AWS"
#     source_identifier = "RDS_SNAPSHOT_ENCRYPTED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "rds-snapshots-public-prohibited" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}rds-snapshots-public-prohibited"
#   description = "Checks if Amazon Relational Database Service (Amazon RDS) snapshots are public. The rule is non-compliant if any existing and new Amazon RDS snapshots are public."
#   source {
#     owner             = "AWS"
#     source_identifier = "RDS_SNAPSHOTS_PUBLIC_PROHIBITED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "rds-storage-encrypted" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}rds-storage-encrypted"
#   description = "Checks whether storage encryption is enabled for your RDS DB instances."
#   source {
#     owner             = "AWS"
#     source_identifier = "RDS_STORAGE_ENCRYPTED"
#   }
#   tags = local.tags
# }
