# -------------------------- gateway --------------------------
resource "aws_api_gateway_rest_api" "custom_api" {
  for_each = local.apigateway_resource

  name        = each.key
  description = var.apigateway.description

  tags = var.default_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_api_gateway_resource" "custom_api_resource" {
  parent_id   = local.rest_api.root_resource_id
  rest_api_id = local.rest_api.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  for_each = toset(local.cognito_user_pool)

  name          = "${var.apigateway.cognito_user_pool_name}__cognito_authorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = local.rest_api.id
  provider_arns = data.aws_cognito_user_pools.selected[each.key].arns
}

resource "aws_api_gateway_method" "custom_api_method" {
  rest_api_id   = local.rest_api.id
  resource_id   = aws_api_gateway_resource.custom_api_resource.id
  http_method   = "ANY"
  authorization = var.apigateway.cognito_user_pool_name != null ? "COGNITO_USER_POOLS" : "NONE"
  authorizer_id = var.apigateway.cognito_user_pool_name != null ? aws_api_gateway_authorizer.cognito_authorizer[var.apigateway.cognito_user_pool_name].id : null

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "custom_api_integration" {
  rest_api_id             = local.rest_api.id
  resource_id             = aws_api_gateway_resource.custom_api_resource.id
  http_method             = aws_api_gateway_method.custom_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function.invoke_arn
}

resource "aws_api_gateway_method" "cors_method" {
  rest_api_id   = local.rest_api.id
  resource_id   = aws_api_gateway_resource.custom_api_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id = local.rest_api.id
  resource_id = aws_api_gateway_resource.custom_api_resource.id
  http_method = aws_api_gateway_method.cors_method.http_method
  type        = "MOCK"
}
resource "aws_api_gateway_stage" "custom_api_stage" {
  rest_api_id   = local.rest_api.id
  stage_name    = var.apigateway.stage_name
  deployment_id = aws_api_gateway_deployment.custom_api_deployment.id
}

resource "aws_api_gateway_deployment" "custom_api_deployment" {
  rest_api_id = local.rest_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method_response.method_response.id,
      aws_api_gateway_integration_response.cors_integration_response.id,
    ]))
  }

  depends_on = [
    aws_api_gateway_integration_response.cors_integration_response,
    aws_api_gateway_integration.custom_api_integration,
  ]

  lifecycle {
    create_before_destroy = true
  }
}
