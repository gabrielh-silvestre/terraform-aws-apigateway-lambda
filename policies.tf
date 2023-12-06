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

# -------------------------- lambda --------------------------
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


resource "aws_iam_role" "lambda_role" {
  name               = "${var.lambda.name}__lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "custom_policies" {
  name = "${var.lambda.name}__custom_policy"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.lambda_policies
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.custom_policies.arn
}
