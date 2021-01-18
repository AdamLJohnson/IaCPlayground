module "userId" {
  source = "./userId"
  parent_resource_id = aws_api_gateway_resource.userResource.id
  aws_iam_role_dynamodb_api_arn = var.aws_iam_role_dynamodb_api_arn
  api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_rest_api" "api" {
  name = "userInfoApi"
  endpoint_configuration {
    types = [ "REGIONAL" ]
  }
}

resource "aws_api_gateway_resource" "userResource" {
  path_part   = "user"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "userPost" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.userResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "userPutItem" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.userResource.id
  http_method = aws_api_gateway_method.userPost.http_method
  integration_http_method = "POST"
  type = "AWS"
  credentials = var.aws_iam_role_dynamodb_api_arn
  uri = "arn:aws:apigateway:us-east-1:dynamodb:action/PutItem"
  request_templates = {
  "application/json" = <<-EOT
    {
      "TableName": "UserInfo",
      "Item": {
        "UserId": {
          "N": "$input.path('$.UserId')"
        },
        "FirstName": {
          "S": "$input.path('$.FirstName')"
        },
        "LastName": {
          "S": "$input.path('$.LastName')"
        }
      }
    }
  EOT
}
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.userResource.id
  http_method = aws_api_gateway_method.userPost.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.userResource.id
  http_method = aws_api_gateway_method.userPost.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  
}

resource "aws_api_gateway_method_response" "response_400" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.userResource.id
  http_method = aws_api_gateway_method.userPost.http_method
  status_code = "400"
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse400" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.userResource.id
  http_method = aws_api_gateway_method.userPost.http_method
  status_code = aws_api_gateway_method_response.response_400.status_code
  selection_pattern = "4\\d{2}"
}


resource "aws_api_gateway_deployment" "devDeployment" {
  depends_on  = [
    aws_api_gateway_integration.userPutItem,
    module.userId.aws_api_gateway_integration_userIdGetItem,
    module.userId.aws_api_gateway_integration_response_userIdGetItemIntegrationResponse200
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "dev"

  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_api_gateway_integration.userPutItem),
      jsonencode(module.userId.aws_api_gateway_integration_userIdGetItem),
      jsonencode(module.userId.aws_api_gateway_integration_response_userIdGetItemIntegrationResponse200),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prodStage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.devDeployment.id
}