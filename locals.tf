locals {
  lambda_policy_list = flatten([
    for policy in var.lambda.policies : {
      name      = "${var.lambda.name}__${policy.name}"
      actions   = policy.actions
      resources = policy.resources
      effect    = "Allow"
    }
  ])
  lambda_policies = {
    for policy in local.lambda_policy_list : policy.name => policy
  }

  apigateway_policy_list = flatten([
    for policy in var.apigateway.policies : {
      name      = "${var.apigateway.name}__${policy.name}"
      actions   = policy.actions
      resources = policy.resources
      effect    = "Allow"
    }
  ])
  apigateway_policies = {
    for policy in local.apigateway_policy_list : policy.name => policy
  }
}
