#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name" {
  type        = string
  description = "(Required) API Gateway Name."
}
variable "description" {
  type        = string
  description = "(Optional) Description of the REST API. If importing an OpenAPI specification via the body argument, this corresponds to the info.description field. If the argument value is provided and is different than the OpenAPI value, the argument value will override the OpenAPI value."
  default     = ""
}
variable "disable_execute_api_endpoint" {
  type        = bool
  description = "(Optional) Whether clients can invoke your API by using the default execute-api endpoint. By default, clients can invoke your API with the default https://{api_id}.execute-api.{region}.amazonaws.com endpoint. To require that clients use a custom domain name to invoke your API, disable the default endpoint. Defaults to false. If importing an OpenAPI specification via the body argument, this corresponds to the x-amazon-apigateway-endpoint-configuration extension disableExecuteApiEndpoint property. If the argument value is true and is different than the OpenAPI value, the argument value will override the OpenAPI value."
  default     = true
}
variable "types" {
  type        = list(string)
  description = "(Optional) List of endpoint types. This resource currently only supports managing a single value. Valid values: EDGE, REGIONAL or PRIVATE. If unspecified, defaults to EDGE. If set to PRIVATE recommend to set put_rest_api_mode = merge to not cause the endpoints and associated Route53 records to be deleted. Refer to the documentation for more information on the difference between edge-optimized and regional APIs."
  default     = ["REGIONAL"]
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags for the workgroup. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = null
}
