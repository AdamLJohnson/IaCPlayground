terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

module "dynamo" {
  source = "./DynamoDb"
}

module "apigw" {
  source = "./ApiGateway"

  aws_iam_role_dynamodb_api_arn = module.iam.aws_iam_role_dynamodb_api_arn
  dynamodb_table_arn = module.dynamo.dynamodb_table_arn
}

module "iam" {
  source = "./Global/iam"

  table_arn = module.dynamo.dynamodb_table_arn
}