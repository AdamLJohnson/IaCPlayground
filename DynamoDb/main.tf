resource "aws_dynamodb_table" "userinfo-table" {
  name           = "UserInfo"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "N"
  }
}