#--------------------------------------------------------------
# DynamoDB table for storing monitor logs.
# Deployed to each monitor region (primary + global when enabled).
# https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest
#--------------------------------------------------------------
module "dynamodb_table_monitor_log" {
  for_each = local.monitor_regions

  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "5.5.0"

  create_table = true
  region       = each.value

  attributes = [
    {
      name = "alarm_name"
      type = "S"
    },
  ]
  autoscaling_enabled         = false
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = true
  hash_key                    = "alarm_name"
  name                        = "${var.name_prefix}monitor-log"
  on_demand_throughput = {
    max_read_request_units  = 3
    max_write_request_units = 3
  }
  point_in_time_recovery_enabled     = true
  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = module.kms_key[each.key].key_arn
  table_class                        = "STANDARD"
  ttl_attribute_name                 = "expires_at"
  ttl_enabled                        = true

  resource_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRoleAccess"
        Effect = "Allow"
        Principal = {
          AWS = module.aws_iam_role_lambda.arn
        }
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
        ]
        Resource = [
          "arn:aws:dynamodb:${each.value}:${data.aws_caller_identity.current.account_id}:table/${var.name_prefix}monitor-log"
        ]
      }
    ]
  })

  tags = var.tags
}
