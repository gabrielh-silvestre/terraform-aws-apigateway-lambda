data "aws_api_gateway_rest_api" "custom_api_data" {
  for_each = var.apigateway.create_api != true ? local.apigateway_resource : []
  name     = each.key
}

data "aws_cognito_user_pools" "selected" {
  for_each = local.cognito_user_pool
  name     = each.key
}

data "aws_dynamodb_table" "table_name" {
  for_each = toset(var.lambda.dynamodb_tables)
  name     = each.key
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${local.function_name}:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.apigateway.cognito_user_pool_name != null ? ["cognito"] : []
    content {
      effect    = "Allow"
      actions   = ["cognito-idp:*"]
      resources = data.aws_cognito_user_pools.selected[var.apigateway.cognito_user_pool_name].arns
    }
  }

  dynamic "statement" {
    for_each = length(var.lambda.dynamodb_tables) > 0 ? ["dynamodb"] : []
    content {
      effect = "Allow"
      actions = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan",
      ]
      resources = [
        for table in var.lambda.dynamodb_tables : data.aws_dynamodb_table.table_name[table].arn
      ]
    }
  }

  dynamic "statement" {
    for_each = length(var.lambda.s3_buckets) > 0 ? ["s3"] : []
    content {
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
      ]
      resources = [
        for bucket in var.lambda.s3_buckets : "arn:aws:s3:::${bucket}/*"
      ]
    }
  }
}

data "aws_security_groups" "functions" {
  filter {
    name   = "tag:${var.lambda.network.security_groups_tag.key}"
    values = var.lambda.network.security_groups_tag.values
  }
}

data "aws_subnets" "functions" {
  filter {
    name   = "tag:${var.lambda.network.subnets_tag.key}"
    values = var.lambda.network.subnets_tag.values
  }
}
