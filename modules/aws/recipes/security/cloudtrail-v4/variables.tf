#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of CloudTrail. Defaults true."
  default     = true
}
variable "is_s3_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable S3 Bucket. Defaults false."
  default     = false
}
variable "aws_kms_key" {
  type = object(
    {
      cloudtrail = object(
        {
          # The description of the key as viewed in AWS console.
          description = string
          # Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days.
          deletion_window_in_days = number
          # Specifies whether the key is enabled. Defaults to true.
          is_enabled = bool
          # Specifies whether key rotation is enabled. Defaults to true.
          enable_key_rotation = bool
          # The display name of the alias. The name must start with the word "alias" followed by a forward slash (alias/)
          alias_name = string
        }
      )
      sns = object(
        {
          # The description of the key as viewed in AWS console.
          description = string
          # Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days.
          deletion_window_in_days = number
          # Specifies whether the key is enabled. Defaults to true.
          is_enabled = bool
          # Specifies whether key rotation is enabled. Defaults to true.
          enable_key_rotation = bool
          # The display name of the alias. The name must start with the word "alias" followed by a forward slash (alias/)
          alias_name = string
        }
      )
    }
  )
  description = "(Optional) The resource of aws_kms_key."
  default = {
    cloudtrail = {
      description             = "This key used for CloudTrail."
      deletion_window_in_days = 7
      is_enabled              = true
      enable_key_rotation     = true
      alias_name              = "alias/cloudtrail"
    }
    sns = {
      description             = "This key used for SNS."
      deletion_window_in_days = 7
      is_enabled              = true
      enable_key_rotation     = true
      alias_name              = "alias/sns"
    }
  }
}
variable "aws_sns_topic" {
  type = object(
    {
      # The name of the topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix
      name = string
      # Creates a unique name beginning with the specified prefix. Conflicts with name
      name_prefix = string
      # The display name for the topic
      display_name = string
      # The fully-formed AWS policy as JSON. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
      delivery_policy = string
      # The IAM role permitted to receive success feedback for this topic
      application_success_feedback_role_arn = string
      # Percentage of success to sample
      application_success_feedback_sample_rate = string
      # IAM role for failure feedback
      application_failure_feedback_role_arn = string
      # The IAM role permitted to receive success feedback for this topic
      http_success_feedback_role_arn = string
      # Percentage of success to sample
      http_success_feedback_sample_rate = string
      # IAM role for failure feedback
      http_failure_feedback_role_arn = string
      # The IAM role permitted to receive success feedback for this topic
      lambda_success_feedback_role_arn = string
      # Percentage of success to sample
      lambda_success_feedback_sample_rate = string
      # IAM role for failure feedback
      lambda_failure_feedback_role_arn = string
      # The IAM role permitted to receive success feedback for this topic
      sqs_success_feedback_role_arn = string
      # Percentage of success to sample
      sqs_success_feedback_sample_rate = string
      # IAM role for failure feedback
      sqs_failure_feedback_role_arn = string
    }
  )
  description = "(Required) The resource of aws_sns_topic."
}
variable "aws_sns_topic_subscription" {
  type = object(
    {
      # Endpoint to send data to. The contents vary with the protocol. See details below.
      endpoint = string
      # Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported. See details below.
      protocol = string
      # Integer indicating number of minutes to wait in retrying mode for fetching subscription arn before marking it as failure. Only applicable for http and https protocols. Default is 1.
      confirmation_timeout_in_minutes = number
      # JSON String with the delivery policy (retries, backoff, etc.) that will be used in the subscription - this only applies to HTTP/S subscriptions. Refer to the SNS docs for more details.
      delivery_policy = string
      # Whether the endpoint is capable of auto confirming subscription (e.g., PagerDuty). Default is false.
      endpoint_auto_confirms = bool
      # JSON String with the filter policy that will be used in the subscription to filter messages seen by the target resource. Refer to the SNS docs for more details.
      filter_policy = string
      # Whether to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property). Default is false.
      raw_message_delivery = string
      # JSON String with the redrive policy that will be used in the subscription. Refer to the SNS docs for more details.
      redrive_policy = string
    }
  )
  description = "(Required) The resource of aws_sns_topic_subscription."
}
variable "aws_cloudwatch_log_group" {
  type = object(
    {
      # The name of the log group. If omitted, Terraform will assign a random, unique name.
      name = string
      # Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.
      retention_in_days = number
    }
  )
  description = "(Required) The resource of aws_cloudwatch_log_group."
}
variable "aws_iam_role" {
  type = object(
    {
      # Description of the role.
      description = string
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) The resource of aws_iam_role."
  default = {
    description = "Role for CloudTrail."
    name        = "security-cloudtrail-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # Description of the IAM policy.
      description = string
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) The resource of aws_iam_policy."
  default = {
    description = "Policy for CloudTrail."
    name        = "security-cloudtrail-policy"
    path        = "/"
  }
}
variable "aws_s3_bucket" {
  type = object(
    {
      # (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be lowercase and less than or equal to 63 characters in length. A full list of bucket naming rules may be found here.
      bucket = string
      # (Optional, Default:false) A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable.
      force_destroy = bool
      # (Optional) A configuration of S3 object locking. See Object Lock Configuration below.
      object_lock_configuration = list(object(
        {
          object_lock_enabled = string
        }
      ))
    }
  )
  description = "(Optional) If you have a new S3 to create, please specify this one. Yes to the variable:aws_s3_bucket_exsiting."
  default     = null
}

variable "aws_s3_bucket_acl" {
  type = object(
    {
      acl                   = string
      access_control_policy = list(any)
      expected_bucket_owner = string

  })
  description = "(Optional) Provides an S3 bucket ACL resource."
  default = {
    acl                   = "private"
    access_control_policy = []
    expected_bucket_owner = null
  }
}
variable "aws_s3_bucket_policy" {
  type = object(
    {
      policy = string
  })
  description = "(Optional) Attaches a policy to an S3 bucket resource."
  default     = null
}

variable "aws_s3_bucket_versioning" {
  type = object(
    {
      versioning_configuration = list(object(
        {
          # (Required) The versioning state of the bucket. Valid values: Enabled or Suspended.
          status = string
          # (Optional) Specifies whether MFA delete is enabled in the bucket versioning configuration. Valid values: Enabled or Disabled.
          mfa_delete = string
        }
      ))
  })
  description = "(Optional) Configuration block for the versioning parameters."
  default = {
    versioning_configuration = [
      {
        status     = "Disabled"
        mfa_delete = "Disabled"
      }
    ]
  }
}
variable "aws_s3_bucket_server_side_encryption_configuration" {
  type = object(
    {
      # (Optional, Forces new resource) The account ID of the expected bucket owner.
      expected_bucket_owner = string
      # (Required) Set of server-side encryption configuration rules. documented below. Currently, only a single rule is supported.
      rule = list(object(
        {
          # (Optional) A single object for setting server-side encryption by default documented below
          apply_server_side_encryption_by_default = list(object(
            {
              # (Required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms
              sse_algorithm = string
              # (Optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms.
              kms_master_key_id = string
            }
          ))
          # (Optional) Whether or not to use Amazon S3 Bucket Keys for SSE-KMS.
          bucket_key_enabled = bool
        }
      ))
    }
  )
  description = "(Optional) Provides a S3 bucket server-side encryption configuration resource."
  default = {
    expected_bucket_owner = null
    rule = [
      {
        apply_server_side_encryption_by_default = [
          {
            sse_algorithm     = "AES256"
            kms_master_key_id = null
          }
        ]
        bucket_key_enabled = null
      }
    ]
  }
}
variable "aws_s3_bucket_logging" {
  type = object(
    {
      # (Optional, Forces new resource) The account ID of the expected bucket owner.
      expected_bucket_owner = string
      # (Required) The bucket where you want Amazon S3 to store server access logs.
      target_bucket = string
      # (Required) A prefix for all log object keys.
      target_prefix = string
      # (Optional) Set of configuration blocks with information for granting permissions documented below.
      target_grant = list(object(
        {
          # (Required) A configuration block for the person being granted permissions documented below.
          grantee = list(object(
            {
              # (Optional) Email address of the grantee. See Regions and Endpoints for supported AWS regions where this argument can be specified.
              email_address = string
              # (Optional) The canonical user ID of the grantee.
              id = string
              # (Required) Type of grantee. Valid values: CanonicalUser, AmazonCustomerByEmail, Group.
              type = string
              # (Optional) URI of the grantee group.
              uri = string
            }
          ))
          # (Required) Logging permissions assigned to the grantee for the bucket. Valid values: FULL_CONTROL, READ, WRITE.
          permission = string
        }
      ))
  })
  description = "(Optional) Provides a S3 bucket logging resource."
  default     = null
}
variable "aws_s3_bucket_lifecycle_configuration" {
  type = object(
    {
      # (Optional) The account ID of the expected bucket owner. If the bucket is owned by a different account, the request will fail with an HTTP 403 (Access Denied) error.
      expected_bucket_owner = string
      # (Required) List of configuration blocks describing the rules managing the replication documented below.
      rule = list(object(
        {
          # (Optional) Configuration block that specifies the days since the initiation of an incomplete multipart upload that Amazon S3 will wait before permanently removing all parts of the upload documented below.
          abort_incomplete_multipart_upload_days = list(object(
            {
              # The number of days after which Amazon S3 aborts an incomplete multipart upload.
              days_after_initiation = number
            }
          ))
          # (Optional) Configuration block that specifies the expiration for the lifecycle of the object in the form of date, days and, whether the object has a delete marker documented below.
          expiration = list(object(
            {
              # (Optional) The date the object is to be moved or deleted. Should be in GMT ISO 8601 Format.
              date = string
              # (Optional) The lifetime, in days, of the objects that are subject to the rule. The value must be a non-zero positive integer.
              days = number
              # (Optional, Conflicts with date and days) Indicates whether Amazon S3 will remove a delete marker with no noncurrent versions. If set to true, the delete marker will be expired; if set to false the policy takes no action.
              expired_object_delete_marker = string
            }
          ))
          # (Optional) Configuration block used to identify objects that a Lifecycle Rule applies to documented below. If not specified, the rule will default to using prefix.
          filter = list(object(
            {
              # (Optional) Configuration block used to apply a logical AND to two or more predicates documented below. The Lifecycle Rule will apply to any object matching all the predicates configured inside the and block.
              and = string
              # (Optional) Minimum object size (in bytes) to which the rule applies.
              object_size_greater_than = number
              # (Optional) Maximum object size (in bytes) to which the rule applies.
              object_size_less_than = number
              # (Optional) Prefix identifying one or more objects to which the rule applies. Defaults to an empty string ("") if not specified.
              prefix = string
              # (Optional) A configuration block for specifying a tag key and value documented below.
              tag = list(object(
                {
                  # (Required) Name of the object key.
                  key = string
                  # (Required) Value of the tag.
                  value = string
                }
              ))
            }
          ))
          # (Required) Unique identifier for the rule. The value cannot be longer than 255 characters.
          id = string
          # (Optional) Configuration block that specifies when noncurrent object versions expire documented below.
          noncurrent_version_expiration = list(object(
            {
              # (Optional) The number of noncurrent versions Amazon S3 will retain. Must be a non-zero positive integer.
              newer_noncurrent_versions = number
              # (Optional) The number of days an object is noncurrent before Amazon S3 can perform the associated action. Must be a positive integer.
              noncurrent_days = number
            }
          ))
          # (Optional) Set of configuration blocks that specify the transition rule for the lifecycle rule that describes when noncurrent objects transition to a specific storage class documented below.
          noncurrent_version_transition = list(object(
            {
              # (Optional) The number of noncurrent versions Amazon S3 will retain.
              newer_noncurrent_versions = number
              # (Optional) The number of days an object is noncurrent before Amazon S3 can perform the associated action.
              noncurrent_days = number
              # (Required) The class of storage used to store the object. Valid Values: GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
              storage_class = string
            }
          ))
          # (Optional) DEPRECATED Use filter instead. This has been deprecated by Amazon S3. Prefix identifying one or more objects to which the rule applies. Defaults to an empty string ("") if filter is not specified.
          prefix = string
          # (Required) Whether the rule is currently being applied. Valid values: Enabled or Disabled.
          status = string
          # (Optional) Set of configuration blocks that specify when an Amazon S3 object transitions to a specified storage class documented below.
          transition = list(object(
            {
              # (Optional, Conflicts with days) The date objects are transitioned to the specified storage class. The date value must be in ISO 8601 format and set to midnight UTC e.g. 2023-01-13T00:00:00Z.
              date = string
              # (Optional, Conflicts with date) The number of days after creation when objects are transitioned to the specified storage class. The value must be a positive integer. If both days and date are not specified, defaults to 0. Valid values depend on storage_class, see Transition objects using Amazon S3 Lifecycle for more details.
              days = string
              # The class of storage used to store the object. Valid Values: GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
              storage_class = string
            }
          ))
        }
        )
      )
    }
  )
  description = "(Optional) Provides an independent configuration resource for S3 bucket lifecycle configuration."
  default     = null
}

variable "s3_replication_configuration_role_arn" {
  type        = string
  description = "(Optional) IAM role ARN to set for the aws_s3_bucket_replication_configuration resource, which does not need to be specified if replication is not performed."
  default     = null
}

variable "aws_s3_bucket_replication_configuration" {
  type = object(
    {
      # (Required) Set of configuration blocks describing the rules managing the replication documented below.
      rule = list(object(
        {
          # (Optional) Whether delete markers are replicated. This argument is only valid with V2 replication configurations (i.e., when filter is used)documented below.
          delete_marker_replication = list(object(
            {
              # (Required) Whether delete markers should be replicated. Either "Enabled" or "Disabled".
              status = string
            }
          ))
          # (Required) Specifies the destination for the rule documented below.
          destination = list(object(
            {
              # (Optional) A configuration block that specifies the overrides to use for object owners on replication documented below. Specify this only in a cross-account scenario (where source and destination bucket owners are not the same), and you want to change replica ownership to the AWS account that owns the destination bucket. If this is not specified in the replication configuration, the replicas are owned by same AWS account that owns the source object. Must be used in conjunction with account owner override configuration.
              access_control_translation = list(object(
                {
                  # (Required) Specifies the replica ownership. For default and valid values, see PUT bucket replication in the Amazon S3 API Reference. Valid values: Destination.
                  owner = string
                }
              ))
              # (Optional) The Account ID to specify the replica ownership. Must be used in conjunction with access_control_translation override configuration.
              account = string
              # (Required) The ARN of the S3 bucket where you want Amazon S3 to store replicas of the objects identified by the rule.
              bucket = string
              # (Optional) A configuration block that provides information about encryption documented below. If source_selection_criteria is specified, you must specify this element.
              encryption_configuration = list(object(
                {
                  # (Required) The ID (Key ARN or Alias ARN) of the customer managed AWS KMS key stored in AWS Key Management Service (KMS) for the destination bucket.
                  replica_kms_key_id = string
                }
              ))
              # (Optional) A configuration block that specifies replication metrics-related settings enabling replication metrics and events documented below.
              metrics = list(object(
                {
                  # (Optional) A configuration block that specifies the time threshold for emitting the s3:Replication:OperationMissedThreshold event documented below.
                  event_threshold = list(object(
                    {
                      # (Required) Time in minutes. Valid values: 15.
                      minutes = string
                    }
                  ))
                  # (Required) The status of the Destination Metrics. Either "Enabled" or "Disabled".
                  status = string
                }
              ))
              # (Optional) A configuration block that specifies S3 Replication Time Control (S3 RTC), including whether S3 RTC is enabled and the time when all objects and operations on objects must be replicated documented below. Replication Time Control must be used in conjunction with metrics.
              replication_time = list(object(
                {
                  # (Required) The status of the Replication Time Control. Either "Enabled" or "Disabled".
                  status = string
                  # (Required) A configuration block specifying the time by which replication should be complete for all objects and operations on objects documented below.
                  time = list(object(
                    {
                      # (Required) Time in minutes. Valid values: 15.
                      minutes = string
                    }
                  ))
                }
              ))
              # (Optional) The storage class used to store the object. By default, Amazon S3 uses the storage class of the source object to create the object replica.
              storage_class = string
            }
          ))

          # (Optional) Replicate existing objects in the source bucket according to the rule configurations documented below.
          existing_object_replication = list(object(
            {
              # (Required) Whether the existing objects should be replicated. Either "Enabled" or "Disabled".
              status = string
            }
          ))
          # (Optional, Conflicts with prefix) Filter that identifies subset of objects to which the replication rule applies documented below.
          filter = list(object(
            {
              # (Optional) A configuration block for specifying rule filters. This element is required only if you specify more than one filter. See and below for more details.
              and = list(object(
                {
                  # (Optional) An object key name prefix that identifies subset of objects to which the rule applies. Must be less than or equal to 1024 characters in length.
                  prefix = string
                  # (Optional, Required if prefix is configured) A map of tags (key and value pairs) that identifies a subset of objects to which the rule applies. The rule applies only to objects having all the tags in its tagset.
                  tags = string
                }
              ))
              # (Optional) An object key name prefix that identifies subset of objects to which the rule applies. Must be less than or equal to 1024 characters in length.
              prefix = string
              # (Optional) A configuration block for specifying a tag key and value documented below.
              tag = list(object(
                {
                  # (Required) Name of the object key.
                  key = string
                  # (Required) Value of the tag.
                  value = string
                }
              ))
            }
          ))
          # (Optional) Unique identifier for the rule. Must be less than or equal to 255 characters in length.
          id = string
          # (Optional, Conflicts with filter) Object key name prefix identifying one or more objects to which the rule applies. Must be less than or equal to 1024 characters in length.
          prefix = string
          # (Optional) The priority associated with the rule. Priority should only be set if filter is configured. If not provided, defaults to 0. Priority must be unique between multiple rules.
          priority = string
          # (Optional) Specifies special object selection criteria documented below.
          source_selection_criteria = list(object(
            {
              # (Optional) A configuration block that you can specify for selections for modifications on replicas. Amazon S3 doesn't replicate replica modifications by default. In the latest version of replication configuration (when filter is specified), you can specify this element and set the status to Enabled to replicate modifications on replicas.
              replica_modifications = list(object(
                {
                  # (Required) Whether the existing objects should be replicated. Either "Enabled" or "Disabled".
                  status = string
                }
              ))
              # (Optional) A configuration block for filter information for the selection of Amazon S3 objects encrypted with AWS KMS. If specified, replica_kms_key_id in destination encryption_configuration must be specified as well.
              sse_kms_encrypted_objects = list(object(
                {
                  # (Required) Whether the existing objects should be replicated. Either "Enabled" or "Disabled".
                  status = string
                }
              ))
            }
          ))
          # (Required) The status of the rule. Either "Enabled" or "Disabled". The rule is ignored if status is not "Enabled".
          status = string
        }
        )
      )
    }
  )
  description = "(Optional) Provides an independent configuration resource for S3 bucket lifecycle configuration."
  default     = null
}

variable "aws_s3_bucket_existing" {
  type = object(
    {
      # The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length.
      bucket_id = string
      # The S3 bucket arn
      bucket_arn = string
    }
  )
  description = "(Optional) If you have an S3 that already exists, please specify this one. It is exclusive to the variable:aws_s3_bucket."
  default     = null
}

variable "aws_cloudtrail" {
  type = object(
    {
      # Name of the trail.
      name = string
      # Enables logging for the trail. Defaults to true. Setting this to false will pause logging.
      enable_logging = bool
      # Whether the trail is publishing events from global services such as IAM to the log files. Defaults to true.
      include_global_service_events = bool
      # Whether the trail is created in the current region or in all regions. Defaults to false.
      is_multi_region_trail = bool
      # Whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account. Defaults to false.
      is_organization_trail = bool
      # Enables logging for the trail. Defaults to true. Setting this to false will pause logging.
      enable_log_file_validation = bool
      # Configuration block of an event selector for enabling data event logging. See details below. Please note the CloudTrail limits when configuring these.
      event_selector = list(any)
      # Configuration block for identifying unusual operational activity. See details below.
      insight_selector = list(any)
    }
  )
  description = "(Optional) The resource of aws_cloudtrail."
  default = {
    name                          = "cloudtrail"
    enable_logging                = true
    include_global_service_events = true
    is_multi_region_trail         = true
    is_organization_trail         = false
    enable_log_file_validation    = true
    event_selector = [
      {
        read_write_type           = "All"
        include_management_events = true
        data_resource = [
          {
            type   = "AWS::S3::Object"
            values = ["arn:aws:s3:::"]
          }
        ]
      }
    ]
    insight_selector = [
      {
        insight_type = "ApiCallRateInsight"
      }
    ]
  }
}
variable "cis_name_prefix" {
  type        = string
  description = "(Required) Center for Internet Security CloudWatch Filter/Alarm name prefix."
}
variable "account_id" {
  type        = string
  description = "(Required) AWS account ID for member account."
}
variable "region" {
  type        = string
  description = "(Required) The region name."
}
variable "user" {
  type        = string
  description = "(Required) IAM user access KMS."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
