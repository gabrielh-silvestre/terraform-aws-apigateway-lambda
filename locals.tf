locals {
  api_gateway_name    = var.resource_prefix != null ? "${var.resource_prefix}__${var.apigateway.name}" : var.apigateway.name
  apigateway_resource = toset(var.apigateway.create_api == true ? [local.api_gateway_name] : [])
  rest_api            = var.apigateway.create_api == true ? aws_api_gateway_rest_api.custom_api[local.api_gateway_name] : data.aws_api_gateway_rest_api.custom_api_data[local.api_gateway_name]
  cognito_user_pool   = toset(var.apigateway.cognito_user_pool_name != null ? [var.apigateway.cognito_user_pool_name] : [])
  function_name       = var.resource_prefix != null ? "${var.resource_prefix}__${var.lambda.name}" : var.lambda.name
}
