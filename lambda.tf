resource "aws_lambda_function" "function" {
  function_name = local.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda.handler
  runtime       = var.lambda.runtime

  s3_bucket = aws_s3_bucket.lambda_s3.id
  s3_key    = aws_s3_object.lambda_s3_object.id

  vpc_config {
    subnet_ids         = local.subnet_ids
    security_group_ids = local.security_group_ids
  }

  tags = var.default_tags
  lifecycle {
    ignore_changes = [tags]
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
resource "null_resource" "build_lambda" {
  for_each = toset(var.lambda.root_dir != null ? ["zip"] : [])

  triggers = {
    version_change = var.lambda.version
  }

  provisioner "local-exec" {
    command = "cp ${var.lambda.root_dir}package.json ${var.lambda.root_dir}package-lock.json ${var.lambda.output_dir}"
  }

  provisioner "local-exec" {
    command = "cd ${var.lambda.output_dir} && npm install --omit=dev && zip -r ${local.function_name}__${var.lambda.version}.zip ."
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "archive_file" "lambda" {
  for_each = toset(var.lambda.filename != null ? ["zip"] : [])

  type        = "zip"
  source_file = var.lambda.filename
  output_path = "${var.lambda.output_dir}/${local.function_name}__${var.lambda.version}.zip"
}
