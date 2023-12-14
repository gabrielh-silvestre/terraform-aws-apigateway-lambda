# Terraform API Gateway with Lambda

Terraform module to create an API Gateway with Lambda integration. Like the Serverless framework, but with Terraform.

## Usage

```hcl
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
  source = "github.com/gabrielh-silvestre/terraform-aws-apigateway-lambda"

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # --------- Only if you want to create a new VPC ---------
  # vpc_cidr_block             = "10.0.0.0/16"
  # public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24"]
  # private_subnet_cidr_blocks = ["10.0.4.0/24", "10.0.5.0/24"]
  # security_group_name        = "example-security-group"

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
    version         = "0.0.0"
    runtime         = "nodejs16.x"
    handler         = "lambda.handler"
    filename        = "lambda.js"
    root_dir        = "./src" # Only if you need to zip a folder
    output_dir      = "./dist"
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
```
