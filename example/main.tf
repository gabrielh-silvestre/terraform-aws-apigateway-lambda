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

  account_id = "318318616248"

  apigateway = {
    stage_name = "dev"

    # cognito_user_pool_id = ["us-east-1_97yyVL4US"]
  }

  lambda = {
    invoke_arn = "arn:aws:lambda:us-east-1:318318616248:function:teste-tinoco"

    name     = "teste-tinoco"
    runtime  = "nodejs16.x"
    handler  = "lambda.handler"
    filename = "./app"

    # s3_buckets = [
    #   "addon-callwe",
    #   "AddonCallwe",
    # ],
    # dynamodb_tables = ["AddonCallwe", "SettingsIntegration"]
  }
}
