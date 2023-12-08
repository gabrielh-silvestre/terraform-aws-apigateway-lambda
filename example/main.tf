provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      safe_delete = "true"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "api-gateway-with-lambda" {
  source = "../"

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  default_tags = {
    "Project" = "terraform-aws-lambda-apigateway"
  }

  resource_prefix = "prefix"
  apigateway = {
    name       = "example_integration"
    stage_name = "test"
  }

  lambda = {
    name            = "trem"
    runtime         = "nodejs16.x"
    handler         = "lambda.handler"
    filename        = "lambda.js"
    dynamodb_tables = ["table1", "table2"]

    network = {
      security_groups_tag = {
        key    = "ExampleKey"
        values = ["Value1", "Value2"]
      }
      subnets_tag = {
        key    = "ExampleKey"
        values = ["Value1", "Value2"]
      }
    }
  }
}
