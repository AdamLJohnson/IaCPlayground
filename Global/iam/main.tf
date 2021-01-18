resource "aws_iam_role" "dynamodb_api" {
  name = "api-ddb"
  assume_role_policy = data.aws_iam_policy_document.apigw.json
}

data "aws_iam_policy_document" "apigw" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "dynamodb_api" {
  name = "DynamoDB-api"
  role = aws_iam_role.dynamodb_api.id
  policy = data.aws_iam_policy_document.dynamodb_api.json
}

data "aws_iam_policy_document" "dynamodb_api" {
  statement {
     actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
    ]

    resources = [
      var.table_arn
    ]
  }
}