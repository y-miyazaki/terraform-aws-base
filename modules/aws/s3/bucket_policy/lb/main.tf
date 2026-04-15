#--------------------------------------------------------------
# Module: aws/s3/bucket_policy/lb
# Purpose: Attach S3 bucket policy to enable ELB and log delivery service to write access logs.
# Notes: Includes ACL enforcement for log delivery; future improvement: regionalize ELB account ID mapping via data source.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  statement {
    sid    = "AWSELBWrite"
    effect = "Allow"
    principals {
      type = "AWS"
      # https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/classic/enable-access-logs.html
      identifiers = ["arn:aws:iam::${var.elb_account_id}:root"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${var.bucket}/*",
    ]
  }
  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${var.bucket}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [
      "arn:aws:s3:::${var.bucket}",
    ]
  }
}

#--------------------------------------------------------------
# Attaches a policy to an S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_policy" "this" {
  count = var.attach_bucket_policy ? 1 : 0

  bucket = var.bucket
  policy = data.aws_iam_policy_document.this.json
}
