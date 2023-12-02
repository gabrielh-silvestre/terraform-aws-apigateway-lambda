# -------------------------- gateway --------------------------
resource "aws_iam_role" "gateway_role" {
  name = "${var.apigateway.name}__custom_role"

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
}

resource "aws_iam_role_policy" "gateway_policies" {
  for_each = local.apigateway_policies

  name = each.value.name
  role = aws_iam_role.gateway_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = each.value.effect
        Action   = each.value.actions
        Resource = each.value.resources
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gateway_role_policy_attachment" {
  for_each = aws_iam_role_policy.gateway_policies

  role       = aws_iam_role.gateway_role.name
  policy_arn = each.value.arn
}

# -------------------------- lambda --------------------------
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda.name}__lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy" "custom_policies" {
  for_each = local.lambda_policies

  name = each.value.name
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = each.value.effect
        Action   = each.value.actions
        Resource = each.value.resources
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  for_each = aws_iam_role_policy.custom_policies

  role       = aws_iam_role.lambda_role.name
  policy_arn = each.value.arn
}
