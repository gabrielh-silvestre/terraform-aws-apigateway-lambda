output "policies" {
  value = data.aws_iam_policy_document.lambda_policy.json
}

output "invoke_url" {
  value = "${aws_api_gateway_deployment.custom_api_deployment.invoke_url}/${aws_api_gateway_resource.custom_api_resource.path_part}"
}
