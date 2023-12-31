# -------------------------- gateway --------------------------
resource "aws_iam_role" "gateway_role" {
  name = "${local.api_gateway_name}__custom_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = var.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_policy" "gateway_permissions" {
  name   = local.api_gateway_name
  policy = data.aws_iam_policy_document.gateway_policy.json

  tags = var.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# -------------------------- lambda --------------------------
resource "aws_iam_role" "lambda_role" {
  name               = "${local.function_name}__lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_policy" "lambda_permissions" {
  name        = "${local.function_name}__lambda_permissions"
  description = "Permissions for ${local.function_name}__lambda"
  policy      = data.aws_iam_policy_document.lambda_policy.json

  tags = var.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_permissions" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_permissions.arn
}
