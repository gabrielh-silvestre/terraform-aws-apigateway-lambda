resource "aws_s3_bucket" "lambda_s3" {
  count = 0

  bucket = lower("${var.lambda.name}lambda")
}

resource "aws_s3_object" "lambda_s3_object" {
  count = 0

  bucket = aws_s3_bucket.lambda_s3[0].id
  key    = "${var.lambda.name}__lambda.zip"
  source = data.archive_file.lambda[0].output_path
}
