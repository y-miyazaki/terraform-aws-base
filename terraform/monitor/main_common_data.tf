#--------------------------------------------------------------
# my account id/region
#--------------------------------------------------------------
data "aws_caller_identity" "current" {}
#--------------------------------------------------------------
# for CloudFront
#--------------------------------------------------------------
data "aws_canonical_user_id" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "current" {}
