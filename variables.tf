variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "default_tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

variable "resource_prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = null
}

variable "lambda" {
  type = object({
    name        = string
    description = optional(string)
    memory_size = optional(number)
    timeout     = optional(number)
    runtime     = string
    handler     = string
    filename    = string
    environment = optional(map(string))

    dynamodb_tables = optional(list(string), [])
    s3_buckets      = optional(list(string), [])
  })

  description = "Configuration for Lambda"
}

variable "apigateway" {
  type = object({
    name        = string
    create_api  = optional(bool, true)
    description = optional(string)
    stage_name  = string

    cognito_user_pool_name = optional(string, null)

    network = optional(object({
      security_group_ids = list(string)
      subnet_ids         = list(string)
    }), null)
  })

  description = "Configuration for API Gateway"
}
