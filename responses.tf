resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id = local.rest_api.id
  resource_id = aws_api_gateway_resource.custom_api_resource.id
  http_method = aws_api_gateway_method.custom_api_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.custom_api_method,
  ]
}

# -------------------------- CORS Mock --------------------------
resource "aws_api_gateway_method_response" "cors_method_response" {
  rest_api_id = local.rest_api.id
  resource_id = aws_api_gateway_resource.custom_api_resource.id
  http_method = aws_api_gateway_method.cors_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [
    aws_api_gateway_method.cors_method,
  ]
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = local.rest_api.id
  resource_id = aws_api_gateway_resource.custom_api_resource.id
  http_method = aws_api_gateway_method.cors_method.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'*'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method_response.cors_method_response,
    aws_api_gateway_integration.cors_integration,
  ]
}
