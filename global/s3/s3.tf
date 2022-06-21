resource "aws_s3_bucket" "terraform_state" {
  bucket = "aleksej-terraform-state"
  lifecycle { # Prevent destroy of the bucket
    prevent_destroy = false
  }
  versioning {
    enabled = true
  }
  server_side_encryption_configuration { #Enable encryption
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
