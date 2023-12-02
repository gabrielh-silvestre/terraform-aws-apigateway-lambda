provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      safe_delete = "true"
    }
  }
}

module "api-gateway-with-lambda" {
  source = "../"

  account_id = "413317021779"

  apigateway = {
    stage_name = "dev"
  }

  lambda = {
    name    = "example"
    runtime = "nodejs16.x"
    handler = "lambda.handler"
    filename = "lambda.js"
  }
}
