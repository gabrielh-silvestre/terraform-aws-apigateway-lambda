resource "aws_lambda_function" "function" {
  function_name = local.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda.handler
  runtime       = var.lambda.runtime

  s3_bucket = aws_s3_bucket.lambda_s3.id
  s3_key    = aws_s3_object.lambda_s3_object.id

  vpc_config {
    subnet_ids         = var.apigateway.network.subnet_ids
    security_group_ids = var.apigateway.network.security_group_ids
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${local.rest_api.execution_arn}/*/*/*"
}

# -------------------------- file --------------------------
data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.lambda.filename
  output_path = "${local.function_name}__lambda.zip"
}
