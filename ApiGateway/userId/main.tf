resource "aws_api_gateway_resource" "userIdResource" {
  path_part   = "{userid}"
  parent_id   = var.parent_resource_id
  rest_api_id = var.api_id
}

resource "aws_api_gateway_method" "userIdGet" {
  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.userIdResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "userIdGetItem" {
  rest_api_id = var.api_id
  resource_id   = aws_api_gateway_resource.userIdResource.id
  http_method = aws_api_gateway_method.userIdGet.http_method
  integration_http_method = "POST"
  type = "AWS"
  credentials = var.aws_iam_role_dynamodb_api_arn
  uri = "arn:aws:apigateway:us-east-1:dynamodb:action/GetItem"
  request_templates = {
  "application/json" = <<-EOT
    {
      "TableName": "UserInfo",
      "Key": {
        "UserId": {
          "N": "$input.params('userid')"
        }
      }
    }
  EOT
}
}

resource "aws_api_gateway_method_response" "userIdresponse_200" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.userIdResource.id
  http_method = aws_api_gateway_method.userIdGet.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "userIdGetItemIntegrationResponse200" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.userIdResource.id
  http_method = aws_api_gateway_method.userIdGet.http_method
  status_code = aws_api_gateway_method_response.userIdresponse_200.status_code
  response_templates = {
  "application/json" = <<-EOT
    #if($input.body == "{}")
      {}
    #else
      #set($inputRoot = $input.path('$').Item)
      {
        "UserId": $inputRoot.UserId.N,
        "FirstName": $inputRoot.FirstName.S,
        "LastName": $inputRoot.LastName.S
      }
    #end
  EOT
}
}

resource "aws_api_gateway_method_response" "userIdresponse_400" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.userIdResource.id
  http_method = aws_api_gateway_method.userIdGet.http_method
  status_code = "400"
}

resource "aws_api_gateway_integration_response" "userIdGetItemIntegrationResponse400" {
  rest_api_id = var.api_id
  resource_id = aws_api_gateway_resource.userIdResource.id
  http_method = aws_api_gateway_method.userIdGet.http_method
  status_code = aws_api_gateway_method_response.userIdresponse_400.status_code
  selection_pattern = "4\\d{2}"
}
