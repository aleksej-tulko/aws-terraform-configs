#Enable blocking for cases when someone else is applying the same terraform script
resource "aws_dynamodb_table" "terraform_blocks" {
  hash_key = "LockID"
  name = "aws-playground-terraform-state"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}