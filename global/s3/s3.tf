resource "aws_s3_bucket" "terraform_state" {
  bucket = "aws-block-terraform-state"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  lifecycle {
    prevent_destroy = false
  }
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}