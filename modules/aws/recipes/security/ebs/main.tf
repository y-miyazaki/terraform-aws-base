#--------------------------------------------------------------
# Provides a resource to manage whether default EBS encryption is enabled for your AWS account in the current AWS region.
# To manage the default KMS key for the region, see the aws_ebs_default_kms_key resource.
#--------------------------------------------------------------
resource "aws_ebs_encryption_by_default" "this" {
  enabled = var.enabled
}
