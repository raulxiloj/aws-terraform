terraform {
    backend "s3" {
        bucket         = "trambo-tf-rx"
        key            = "state/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "terraform-state"
    }
}

resource "aws_s3_bucket" "terraform-state" {
    bucket = "trambo-tf-rx"
}

resource "aws_s3_bucket_public_access_block" "block" {
    bucket = aws_s3_bucket.terraform-state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform-state" {
    name           = "terraform-state"
    read_capacity = 10
    write_capacity = 10
    hash_key       = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}