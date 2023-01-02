output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "The ARN of S3 bucket"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_blocks.arn
  description = "The name of DynamoDB table"
}