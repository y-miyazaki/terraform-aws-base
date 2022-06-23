#--------------------------------------------------------------
# Provides IAM Policy document.
#--------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  version = "2012-10-17"

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      var.bucket_arn
    ]
  }
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${var.bucket_arn}/AWSLogs/${var.account_id}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
#--------------------------------------------------------------
# Attaches a policy to an S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_policy" "this" {
  count  = var.attach_bucket_policy ? 1 : 0
  bucket = var.bucket
  policy = data.aws_iam_policy_document.this.json
}
