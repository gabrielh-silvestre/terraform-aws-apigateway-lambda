locals {
  count_index_default = 0
  api_gateway_name    = var.resource_prefix != null ? "${var.resource_prefix}__${var.apigateway.name}" : var.apigateway.name
  rest_api            = var.apigateway.create_api == true ? aws_api_gateway_rest_api.custom_api[local.count_index_default] : data.aws_api_gateway_rest_api.custom_api_data[local.count_index_default]
  cognito_user_pool   = toset(var.apigateway.cognito_user_pool_name != null ? [var.apigateway.cognito_user_pool_name] : [])
  function_name       = var.resource_prefix != null ? "${var.resource_prefix}__${var.lambda.name}" : var.lambda.name
}
