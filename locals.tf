locals {
  cloudwatch_policy = [{
    Effect   = "Allow"
    Action   = "logs:*"
    Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${var.lambda.name}__lambda:*"
  }]

  gtw_authorization_arns = flatten([
    for user_pool_id in var.apigateway.cognito_user_pool_id : [
      "arn:aws:cognito-idp:${var.region}:${var.account_id}:userpool/${user_pool_id}"
    ]
  ])
  cognito_policy = length(local.gtw_authorization_arns) > 0 ? [{
    Effect   = "Allow"
    Action   = "cognito-idp:*"
    Resource = local.gtw_authorization_arns
  }] : []

  dynamodb_policy = length(var.lambda.dynamodb_tables) > 0 ? flatten([
    for table in var.lambda.dynamodb_tables : [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
        ]
        Resource = [
          "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${table}"
        ]
      }
    ]
  ]) : []

  s3_policy = length(var.lambda.s3_buckets) > 0 ? flatten([
    for bucket in var.lambda.s3_buckets : [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          "arn:aws:s3:::${bucket}/*"
        ]
      }
    ]
  ]) : []

  all_lambda_policies = [
    local.cloudwatch_policy,
    local.dynamodb_policy,
    local.s3_policy,
  ]
  lambda_policies = flatten(local.all_lambda_policies)


  gtw_authorization = length(var.apigateway.cognito_user_pool_id) > 0 ? "COGNITO_USER_POOLS" : "NONE"
  gtw_authorizer_id = length(var.apigateway.cognito_user_pool_id) > 0 ? aws_api_gateway_authorizer.cognito_authorizer.id : null
}
