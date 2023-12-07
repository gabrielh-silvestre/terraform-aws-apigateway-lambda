# -------------------------- gateway --------------------------
resource "aws_api_gateway_rest_api" "custom_api" {
  name        = var.apigateway.name != "" ? var.apigateway.name : "${var.lambda.name}__api"
  description = var.apigateway.description
}

resource "aws_api_gateway_resource" "custom_api_resource" {
  parent_id   = aws_api_gateway_rest_api.custom_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.custom_api.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.custom_api.id
  provider_arns = local.gtw_authorization_arns
}

resource "aws_api_gateway_method" "custom_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.custom_api.id
  resource_id   = aws_api_gateway_resource.custom_api_resource.id
  http_method   = "ANY"
  authorization = local.gtw_authorization
  authorizer_id = local.gtw_authorizer_id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "custom_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.custom_api.id
  resource_id             = aws_api_gateway_resource.custom_api_resource.id
  http_method             = aws_api_gateway_method.custom_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda.invoke_arn != null ? var.lambda.invoke_arn : aws_lambda_function[count.index].lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "custom_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.custom_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method_response.method_response.id,
      aws_api_gateway_integration_response.cors_integration_response.id,
    ]))
  }

  depends_on = [
    aws_api_gateway_integration_response.cors_integration_response,
    aws_api_gateway_integration.custom_api_integration,
    aws_api_gateway_resource.custom_api_resource,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "custom_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.custom_api.id
  stage_name    = var.apigateway.stage_name
  deployment_id = aws_api_gateway_deployment.custom_api_deployment.id
}

# -------------------------- Enable CORS preflight --------------------------
resource "aws_api_gateway_method" "cors_method" {
  rest_api_id   = aws_api_gateway_rest_api.custom_api.id
  resource_id   = aws_api_gateway_resource.custom_api_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id = aws_api_gateway_rest_api.custom_api.id
  resource_id = aws_api_gateway_resource.custom_api_resource.id
  http_method = aws_api_gateway_method.cors_method.http_method
  type        = "MOCK"
}
