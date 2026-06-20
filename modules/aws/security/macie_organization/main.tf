#--------------------------------------------------------------
# Module: aws/security/macie_organization
# Purpose: Configure Amazon Macie for organization-wide management.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

resource "aws_macie2_account" "this" {
  count = var.is_enabled ? 1 : 0

  region                       = local.region
  status                       = var.status
  finding_publishing_frequency = var.finding_publishing_frequency
}

resource "aws_macie2_organization_admin_account" "this" {
  count = var.is_enabled && var.is_enabled_admin ? 1 : 0

  region           = local.region
  admin_account_id = var.admin_account_id

  depends_on = [aws_macie2_account.this]
}

resource "aws_macie2_organization_configuration" "this" {
  count = var.is_enabled ? 1 : 0

  region      = local.region
  auto_enable = var.auto_enable

  depends_on = [
    aws_macie2_account.this,
    aws_macie2_organization_admin_account.this,
  ]
}

#--------------------------------------------------------------
# Classification Jobs
#--------------------------------------------------------------
resource "aws_macie2_classification_job" "this" {
  for_each = var.is_enabled ? { for job in var.classification_jobs : job.name => job } : {}

  region                     = local.region
  job_type                   = each.value.job_type
  name                       = each.value.name
  description                = try(each.value.description, null)
  sampling_percentage        = try(each.value.sampling_percentage, null)
  initial_run                = try(each.value.initial_run, null)
  job_status                 = try(each.value.job_status, null)
  custom_data_identifier_ids = try(each.value.custom_data_identifier_ids, null)

  dynamic "s3_job_definition" {
    for_each = try([each.value.s3_job_definition], [])
    content {
      dynamic "bucket_definitions" {
        for_each = try(s3_job_definition.value.bucket_definitions, [])
        content {
          account_id = bucket_definitions.value.account_id
          buckets    = bucket_definitions.value.buckets
        }
      }
      dynamic "bucket_criteria" {
        for_each = try([s3_job_definition.value.bucket_criteria], [])
        content {
          dynamic "excludes" {
            for_each = try([bucket_criteria.value.excludes], [])
            content {
              dynamic "and" {
                for_each = try(excludes.value.and, [])
                content {
                  dynamic "simple_criterion" {
                    for_each = try([and.value.simple_criterion], [])
                    content {
                      comparator = simple_criterion.value.comparator
                      key        = simple_criterion.value.key
                      values     = simple_criterion.value.values
                    }
                  }
                  dynamic "tag_criterion" {
                    for_each = try([and.value.tag_criterion], [])
                    content {
                      comparator = tag_criterion.value.comparator
                      dynamic "tag_values" {
                        for_each = try(tag_criterion.value.tag_values, [])
                        content {
                          key   = tag_values.value.key
                          value = tag_values.value.value
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          dynamic "includes" {
            for_each = try([bucket_criteria.value.includes], [])
            content {
              dynamic "and" {
                for_each = try(includes.value.and, [])
                content {
                  dynamic "simple_criterion" {
                    for_each = try([and.value.simple_criterion], [])
                    content {
                      comparator = simple_criterion.value.comparator
                      key        = simple_criterion.value.key
                      values     = simple_criterion.value.values
                    }
                  }
                  dynamic "tag_criterion" {
                    for_each = try([and.value.tag_criterion], [])
                    content {
                      comparator = tag_criterion.value.comparator
                      dynamic "tag_values" {
                        for_each = try(tag_criterion.value.tag_values, [])
                        content {
                          key   = tag_values.value.key
                          value = tag_values.value.value
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      dynamic "scoping" {
        for_each = try([s3_job_definition.value.scoping], [])
        content {
          dynamic "excludes" {
            for_each = try([scoping.value.excludes], [])
            content {
              dynamic "and" {
                for_each = try(excludes.value.and, [])
                content {
                  dynamic "simple_scope_term" {
                    for_each = try([and.value.simple_scope_term], [])
                    content {
                      comparator = try(simple_scope_term.value.comparator, null)
                      key        = try(simple_scope_term.value.key, null)
                      values     = try(simple_scope_term.value.values, null)
                    }
                  }
                  dynamic "tag_scope_term" {
                    for_each = try([and.value.tag_scope_term], [])
                    content {
                      comparator = try(tag_scope_term.value.comparator, null)
                      key        = tag_scope_term.value.key
                      target     = tag_scope_term.value.target
                      dynamic "tag_values" {
                        for_each = try(tag_scope_term.value.tag_values, [])
                        content {
                          key   = tag_values.value.key
                          value = tag_values.value.value
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          dynamic "includes" {
            for_each = try([scoping.value.includes], [])
            content {
              dynamic "and" {
                for_each = try(includes.value.and, [])
                content {
                  dynamic "simple_scope_term" {
                    for_each = try([and.value.simple_scope_term], [])
                    content {
                      comparator = try(simple_scope_term.value.comparator, null)
                      key        = try(simple_scope_term.value.key, null)
                      values     = try(simple_scope_term.value.values, null)
                    }
                  }
                  dynamic "tag_scope_term" {
                    for_each = try([and.value.tag_scope_term], [])
                    content {
                      comparator = try(tag_scope_term.value.comparator, null)
                      key        = tag_scope_term.value.key
                      target     = tag_scope_term.value.target
                      dynamic "tag_values" {
                        for_each = try(tag_scope_term.value.tag_values, [])
                        content {
                          key   = tag_values.value.key
                          value = tag_values.value.value
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "schedule_frequency" {
    for_each = try([each.value.schedule_frequency], [])
    content {
      daily_schedule   = try(schedule_frequency.value.daily_schedule, null)
      weekly_schedule  = try(schedule_frequency.value.weekly_schedule, null)
      monthly_schedule = try(schedule_frequency.value.monthly_schedule, null)
    }
  }

  tags = try(each.value.tags, var.tags)

  depends_on = [aws_macie2_account.this]
}

#--------------------------------------------------------------
# Findings Filters
#--------------------------------------------------------------
resource "aws_macie2_findings_filter" "this" {
  for_each = var.is_enabled ? { for filter in var.findings_filters : filter.name => filter } : {}

  region      = local.region
  name        = each.value.name
  action      = each.value.action
  description = try(each.value.description, null)
  position    = try(each.value.position, null)

  finding_criteria {
    dynamic "criterion" {
      for_each = try(each.value.finding_criteria.criterion, [])
      content {
        field          = criterion.value.field
        eq             = try(criterion.value.eq, null)
        neq            = try(criterion.value.neq, null)
        lt             = try(criterion.value.lt, null)
        lte            = try(criterion.value.lte, null)
        gt             = try(criterion.value.gt, null)
        gte            = try(criterion.value.gte, null)
        eq_exact_match = try(criterion.value.eq_exact_match, null)
      }
    }
  }

  tags = try(each.value.tags, var.tags)

  depends_on = [aws_macie2_account.this]
}
