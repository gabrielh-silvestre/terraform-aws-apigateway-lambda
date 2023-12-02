resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id = aws_api_gateway_rest_api.custom_api.id
  resource_id = aws_api_gateway_resource.custom_api_resource.id
  http_method = aws_api_gateway_method.custom_api_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# NOTE: This is the response for CORS preflight request
resource "aws_api_gateway_integration_response" "name" {
  rest_api_id = aws_api_gateway_rest_api.custom_api.id
  resource_id = aws_api_gateway_integration.custom_api_integration.resource_id
  http_method = aws_api_gateway_method.custom_api_method.http_method
  status_code = aws_api_gateway_method_response.method_response.status_code

  response_templates = {
    "application/json" = ""
  }
}
