output "policies" {
  value = data.aws_iam_policy_document.lambda_policy.json
}
