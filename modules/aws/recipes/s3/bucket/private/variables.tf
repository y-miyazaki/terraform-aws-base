#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_random_name_suffix" {
  type        = bool
  description = "(Optional) The random name suffix of the bucket."
  default     = false
}
variable "bucket" {
  type        = string
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  default     = null
}
variable "bucket_prefix" {
  type        = string
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  default     = null
}
variable "acl" {
  type        = string
  description = "(Optional) The canned ACL to apply. Defaults to private."
  default     = "private"
}
variable "policy" {
  type        = string
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the bucket."
  default     = null
}
variable "force_destroy" {
  type        = bool
  description = "(Optional, Default:false) A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}
# variable "website" {
#   description = "(Optional) A website object (documented below)."
#   default     = []
# }
# variable "cors_rule" {
#   description = "(Optional) A rule of Cross-Origin Resource Sharing (documented below)."
#   default     = []
# }
variable "versioning" {
  description = "(Optional) A state of versioning (documented below)"
  default     = []
}
variable "logging" {
  description = "(Optional) A settings of bucket logging (documented below)."
  default     = []
}
variable "lifecycle_rule" {
  description = "(Optional) A configuration of object lifecycle management (documented below)."
  default     = []
}
variable "acceleration_status" {
  type        = string
  description = "(Optional) Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended."
  default     = null
}
variable "region" {
  type        = string
  description = "(Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee."
  default     = null
}
variable "request_payer" {
  type        = string
  description = "(Optional) Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information."
  default     = null
}
variable "replication_configuration" {
  description = "(Optional) A configuration of replication configuration (documented below)."
  default     = []
}
variable "server_side_encryption_configuration" {
  description = "(Optional) A configuration of server-side encryption configuration (documented below)"
  default     = []
}
variable "object_lock_configuration" {
  description = "(Optional) A configuration of S3 object locking (documented below)"
  default     = []
}
