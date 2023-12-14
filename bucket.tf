resource "aws_s3_bucket" "lambda_s3" {
  bucket = lower("${var.lambda.name}lambda")

  tags = var.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_s3_object" "lambda_s3_object" {
  bucket = aws_s3_bucket.lambda_s3.id
  key    = "${var.lambda.name}__${var.lambda.version}.zip"
  source = "${var.lambda.output_dir}/${local.function_name}__${var.lambda.version}.zip"

  tags = var.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}
