locals {
  cloudwatch_policy = {
    Effect   = "Allow"
    Action   = "logs:*"
    Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${var.lambda.name}__lambda:*"
  }

  dynamodb_policy = var.lambda.dynamodb_table != null ? {
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
      "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.lambda.dynamodb_table}"
    ]
  } : null

  s3_policy = var.lambda.s3_bucket != null ? {
    Effect = "Allow"
    Action = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    Resource = [
      "arn:aws:s3:::${var.lambda.s3_bucket}/*"
    ]
  } : null

  all_lambda_policies = [
    local.cloudwatch_policy,
    local.dynamodb_policy,
    local.s3_policy,
  ]
  lambda_policies = [
    for policy in local.all_lambda_policies : {
      Effect   = policy.Effect
      Action   = policy.Action
      Resource = policy.Resource
    }
    if policy != null
  ]
}
