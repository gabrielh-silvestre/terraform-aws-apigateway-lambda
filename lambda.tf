resource "aws_lambda_function" "lambda" {
  function_name = var.lambda.name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda.handler
  runtime       = "nodejs16.x"

  s3_bucket = aws_s3_bucket.lambda_s3.id
  s3_key    = aws_s3_object.lambda_s3_object.id
}

# -------------------------- policies --------------------------
resource "aws_lambda_permission" "apigw_lambda" {
  function_name = aws_lambda_function.lambda.function_name
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.custom_api.id}/*/*"

  depends_on = [
    aws_api_gateway_rest_api.custom_api,
    aws_api_gateway_resource.custom_api_resource
  ]
}

# -------------------------- logging --------------------------
resource "aws_cloudwatch_log_group" "default" {
  name = "/lambda/${var.lambda.name}__lambda"
}

# -------------------------- file --------------------------
data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.lambda.filename
  output_path = "${var.lambda.name}__lambda.zip"
}
