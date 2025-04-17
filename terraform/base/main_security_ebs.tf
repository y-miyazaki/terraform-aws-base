#--------------------------------------------------------------
# For EBS
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a resource to manage whether default EBS encryption is enabled for your AWS account in the current AWS region.
# To manage the default KMS key for the region, see the aws_ebs_default_kms_key resource.
#--------------------------------------------------------------
module "aws_security_ebs" {
  source     = "../../modules/aws/security/ebs"
  is_enabled = lookup(var.security_ebs, "is_enabled", true)
}
