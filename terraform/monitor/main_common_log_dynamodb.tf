#--------------------------------------------------------------
# This module creates a DynamoDB table for storing monitor logs.
# https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest
#--------------------------------------------------------------
module "dynamodb_table_monitor_log" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "5.3.0"

  name                = "${var.name_prefix}monitor-log"
  autoscaling_enabled = false
  attributes = [
    {
      name = "alarm_name"
      type = "S"
    },
  ]
  billing_mode = "PAY_PER_REQUEST"
  #   global_secondary_indexes = [
  #     {
  #       name               = "AlarmIndex"
  #       hash_key           = "alarm_name"
  #       range_key          = "slack_ts"
  #       projection_type    = "INCLUDE"
  #       non_key_attributes = ["id"]

  #       on_demand_throughput = {
  #         max_write_request_units = 1
  #         max_read_request_units  = 1
  #       }
  #     }
  #   ]
  deletion_protection_enabled        = true
  hash_key                           = "alarm_name"
  point_in_time_recovery_enabled     = true
  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = module.kms_key["monitor"].key_arn
  table_class                        = "STANDARD"
  ttl_attribute_name                 = "expires_at"
  ttl_enabled                        = true
  on_demand_throughput = {
    max_read_request_units  = 3
    max_write_request_units = 3
  }

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
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.name_prefix}monitor-log"
        ]
      }
    ]
  })

  tags = var.tags
}
