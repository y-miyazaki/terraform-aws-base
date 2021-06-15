#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  version = "2012-10-17"
  statement {
    sid    = "AllowLBPutAccessLog"
    effect = "Allow"
    principals {
      type = "AWS"
      # see principal account list
      # https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
      identifiers = [
        var.principal_account_id,
      ]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${var.bucket_arn}/*",
    ]
  }
}
#--------------------------------------------------------------
# Attaches a policy to an S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_policy" "this" {
  bucket = var.bucket
  policy = data.aws_iam_policy_document.this.json
}
