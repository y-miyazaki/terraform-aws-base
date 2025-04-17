#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  version = "2012-10-17"

  statement {
    sid    = "AllowRedshift"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket}",
      "arn:aws:s3:::${var.bucket}/*"
    ]
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
