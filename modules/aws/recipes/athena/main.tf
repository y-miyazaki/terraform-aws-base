#--------------------------------------------------------------
# Provides an Athena Workgroup.
#--------------------------------------------------------------
# tfsec:ignore:aws-athena-enable-at-rest-encryption
# tfsec:ignore:aws-athena-no-encryption-override
resource "aws_athena_workgroup" "this" {
  name = format("%s%s", var.name_prefix, var.workgroup_name)
  dynamic "configuration" {
    for_each = length(keys(var.workgroup_configuration)) == 0 ? [] : [var.workgroup_configuration]
    content {
      bytes_scanned_cutoff_per_query  = lookup(configuration.value, "bytes_scanned_cutoff_per_query", null)
      enforce_workgroup_configuration = lookup(configuration.value, "enforce_workgroup_configuration", true)
      dynamic "engine_version" {
        for_each = lookup(configuration.value, "engine_version", [])
        content {
          selected_engine_version = lookup(engine_version.value, "selected_engine_version", null)
        }
      }
      publish_cloudwatch_metrics_enabled = lookup(configuration.value, "publish_cloudwatch_metrics_enabled", true)
      dynamic "result_configuration" {
        for_each = length(keys(lookup(configuration.value, "result_configuration", {}))) == 0 ? [] : [lookup(configuration.value, "result_configuration", {})]
        content {
          dynamic "encryption_configuration" {
            for_each = length(keys(lookup(result_configuration.value, "encryption_configuration", {}))) == 0 ? [] : [lookup(result_configuration.value, "encryption_configuration", {})]
            content {
              encryption_option = lookup(encryption_configuration.value, "encryption_option")
              kms_key_arn       = lookup(encryption_configuration.value, "kms_key_arn", null)
            }
          }
          dynamic "acl_configuration" {
            for_each = length(keys(lookup(result_configuration.value, "acl_configuration", {}))) == 0 ? [] : [lookup(result_configuration.value, "acl_configuration", {})]
            content {
              s3_acl_option = lookup(acl_configuration.value, "s3_acl_option", null)
            }
          }
          expected_bucket_owner = lookup(result_configuration.value, "expected_bucket_owner", null)
          output_location       = lookup(result_configuration.value, "output_location", null)
        }
      }
      requester_pays_enabled = lookup(configuration.value, "requester_pays_enabled", null)
    }
  }
  description   = var.workgroup_description
  state         = var.workgroup_state
  tags          = var.tags
  force_destroy = true
}

#--------------------------------------------------------------
# Provides an Athena database.
#--------------------------------------------------------------
# tfsec:ignore:aws-athena-enable-at-rest-encryption
resource "aws_athena_database" "this" {
  bucket = var.database_bucket
  name   = format("%s_%s", trimsuffix(var.name_prefix, "-"), var.database_name)
  dynamic "acl_configuration" {
    for_each = length(keys(var.database_acl_configuration)) == 0 ? [] : [var.database_acl_configuration]
    content {
      s3_acl_option = lookup(acl_configuration.value, "s3_acl_option", "BUCKET_OWNER_FULL_CONTROL")
    }
  }
  comment = var.database_comment
  dynamic "encryption_configuration" {
    for_each = length(keys(var.database_encryption_configuration)) == 0 ? [] : [var.database_encryption_configuration]
    content {
      encryption_option = lookup(encryption_configuration.value, "encryption_option")
      kms_key           = lookup(encryption_configuration.value, "kms_key", null)
    }
  }
  expected_bucket_owner = var.database_expected_bucket_owner
  properties            = var.database_properties
  force_destroy         = true
  depends_on = [
    aws_athena_workgroup.this
  ]
}

#--------------------------------------------------------------
# Provides an Athena Named Query resource.
# For CloudFront
#--------------------------------------------------------------
data "template_file" "cloudfront_drop_table" {
  count    = var.enabled_cloudfront ? 1 : 0
  template = file("${path.module}/sql/table_drop.sql.tpl")
  vars = {
    athena_database_name = aws_athena_database.this.name
    athena_table_name    = var.cloudfront_table_name
    log_bucket           = var.cloudfront_log_bucket
  }
}
data "template_file" "cloudfront_create_table" {
  count    = var.enabled_cloudfront ? 1 : 0
  template = file("${path.module}/sql/cloudfront_table.sql.tpl")
  vars = {
    athena_database_name = aws_athena_database.this.name
    athena_table_name    = var.cloudfront_table_name
    log_bucket           = var.cloudfront_log_bucket
  }
}
# resource "aws_athena_named_query" "cloudfront_create_table" {
#   count       = var.enabled_cloudfront ? 1 : 0
#   name        = "cloudfront_table"
#   description = "Table of CloudFront."
#   workgroup   = aws_athena_workgroup.this.id
#   database    = aws_athena_database.this.name
#   query       = data.template_file.cloudfront_create_table[0].rendered
# }
resource "null_resource" "cloudfront_create_table" {
  count = var.enabled_cloudfront ? 1 : 0
  triggers = {
    workgroup    = aws_athena_workgroup.this.id
    database     = aws_athena_database.this.id
    query_string = data.template_file.cloudfront_create_table[0].rendered
  }

  provisioner "local-exec" {
    command = <<-EOF
      aws athena start-query-execution \
        --work-group "${aws_athena_workgroup.this.id}" \
        --query-execution-context Database="${aws_athena_database.this.id}" \
        --query-string "${replace(replace(replace(data.template_file.cloudfront_drop_table[0].rendered, "`", "\\`"), "\"", "\\\""), "$", "\\$")}"
      sleep 3
      aws athena start-query-execution \
        --work-group "${aws_athena_workgroup.this.id}" \
        --query-execution-context Database="${aws_athena_database.this.id}" \
        --query-string "${replace(replace(replace(data.template_file.cloudfront_create_table[0].rendered, "`", "\\`"), "\"", "\\\""), "$", "\\$")}"
      sleep 20
    EOF
  }
}

#--------------------------------------------------------------
# Provides an Athena Named Query resource.
# For CloudFront
#--------------------------------------------------------------
data "template_file" "cloudfront_query_1week_error" {
  count    = var.enabled_cloudfront ? 1 : 0
  template = file("${path.module}/sql/cloudfront_query_1week_error.sql.tpl")
  vars = {
    athena_database_name = aws_athena_database.this.name
    athena_table_name    = var.cloudfront_table_name
    log_bucket           = var.cloudfront_log_bucket
  }
}
resource "aws_athena_named_query" "cloudfront_query_1week_error" {
  count       = var.enabled_cloudfront ? 1 : 0
  name        = format("%s%s", var.name_prefix, "cloudfront-1week-error")
  description = "List errors encountered by CloudFront for a week, with no duplicate URIs.."
  workgroup   = aws_athena_workgroup.this.id
  database    = aws_athena_database.this.name
  query       = data.template_file.cloudfront_query_1week_error[0].rendered
}

#--------------------------------------------------------------
# Provides an Athena Named Query resource.
# For SES
#--------------------------------------------------------------
data "template_file" "ses_drop_table" {
  count    = var.enabled_ses ? 1 : 0
  template = file("${path.module}/sql/table_drop.sql.tpl")
  vars = {
    athena_database_name = aws_athena_database.this.name
    athena_table_name    = var.ses_table_name
    log_bucket           = var.ses_log_bucket
  }
}
data "template_file" "ses_create_table" {
  count    = var.enabled_ses ? 1 : 0
  template = file("${path.module}/sql/ses_table.sql.tpl")
  vars = {
    athena_database_name = aws_athena_database.this.name
    athena_table_name    = var.ses_table_name
    log_bucket           = var.ses_log_bucket
  }
}
resource "null_resource" "ses_create_table" {
  count = var.enabled_ses ? 1 : 0
  triggers = {
    workgroup    = aws_athena_workgroup.this.id
    database     = aws_athena_database.this.id
    query_string = data.template_file.ses_create_table[0].rendered
  }
  provisioner "local-exec" {
    command = <<-EOF
      aws athena start-query-execution \
        --work-group "${aws_athena_workgroup.this.id}" \
        --query-execution-context Database="${aws_athena_database.this.id}" \
        --query-string "${replace(replace(replace(data.template_file.ses_drop_table[0].rendered, "`", "\\`"), "\"", "\\\""), "$", "\\$")}"
      sleep 3
      aws athena start-query-execution \
        --work-group "${aws_athena_workgroup.this.id}" \
        --query-execution-context Database="${aws_athena_database.this.id}" \
        --query-string "${replace(replace(replace(data.template_file.ses_create_table[0].rendered, "`", "\\`"), "\"", "\\\""), "$", "\\$")}"
      sleep 20
    EOF
  }
}
data "template_file" "ses_create_view" {
  count    = var.enabled_ses ? 1 : 0
  template = file("${path.module}/sql/ses_view.sql.tpl")
  vars = {
    athena_database_name = aws_athena_database.this.name
    athena_table_name    = var.ses_table_name
  }
}
resource "null_resource" "ses_create_view" {
  count = var.enabled_ses ? 1 : 0
  triggers = {
    workgroup    = aws_athena_workgroup.this.id
    database     = aws_athena_database.this.id
    query_string = data.template_file.ses_create_view[0].rendered
  }
  provisioner "local-exec" {
    command = <<-EOF
      aws athena start-query-execution \
        --work-group "${aws_athena_workgroup.this.id}" \
        --query-execution-context Database="${aws_athena_database.this.id}" \
        --query-string "${replace(replace(replace(data.template_file.ses_create_view[0].rendered, "`", "\\`"), "\"", "\\\""), "$", "\\$")}"
    EOF
  }
  depends_on = [
    null_resource.ses_create_table
  ]
}
#--------------------------------------------------------------
# Provides an Athena Named Query resource.
# For SES
#--------------------------------------------------------------
data "template_file" "ses_query_bounce_hard_1week" {
  count    = var.enabled_ses ? 1 : 0
  template = file("${path.module}/sql/ses_query_bounce_hard_1week.sql.tpl")
  vars = {
    athena_database_name = aws_athena_database.this.name
    athena_table_name    = var.ses_table_name
    log_bucket           = var.ses_log_bucket
  }
}
data "template_file" "ses_query_bounce_soft_1week" {
  count    = var.enabled_ses ? 1 : 0
  template = file("${path.module}/sql/ses_query_bounce_soft_1week.sql.tpl")
  vars = {
    athena_database_name = aws_athena_database.this.name
    athena_table_name    = var.ses_table_name
    log_bucket           = var.ses_log_bucket
  }
}
data "template_file" "ses_query_bounce_all_1week" {
  count    = var.enabled_ses ? 1 : 0
  template = file("${path.module}/sql/ses_query_bounce_all_1week.sql.tpl")
  vars = {
    athena_database_name = aws_athena_database.this.name
    athena_table_name    = var.ses_table_name
    log_bucket           = var.ses_log_bucket
  }
}
resource "aws_athena_named_query" "ses_query_bounce_hard_1week" {
  count       = var.enabled_ses ? 1 : 0
  name        = format("%s%s", var.name_prefix, "ses-bounce-hard-1week")
  description = "List hard bounces generated by SES for one week."
  workgroup   = aws_athena_workgroup.this.id
  database    = aws_athena_database.this.name
  query       = data.template_file.ses_query_bounce_hard_1week[0].rendered
}
resource "aws_athena_named_query" "ses_query_bounce_soft_1week" {
  count       = var.enabled_ses ? 1 : 0
  name        = format("%s%s", var.name_prefix, "ses-bounce-soft-1week")
  description = "List soft bounces generated by SES for one week."
  workgroup   = aws_athena_workgroup.this.id
  database    = aws_athena_database.this.name
  query       = data.template_file.ses_query_bounce_soft_1week[0].rendered
}
resource "aws_athena_named_query" "ses_query_bounce_all_1week" {
  count       = var.enabled_ses ? 1 : 0
  name        = format("%s%s", var.name_prefix, "ses-bounce-all-1week")
  description = "List all bounces generated by SES for one week."
  workgroup   = aws_athena_workgroup.this.id
  database    = aws_athena_database.this.name
  query       = data.template_file.ses_query_bounce_all_1week[0].rendered
}
