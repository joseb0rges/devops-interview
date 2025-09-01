locals {
  bucket_name = "${var.app_name}-${var.env}-mtls-truststore"
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_policy" "allow_elb_read" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowALBReadTrustStore",
      Effect    = "Allow",
      Principal = { Service = "elasticloadbalancing.amazonaws.com" },
      Action    = ["s3:GetObject","s3:GetBucketLocation","s3:ListBucket"],
      Resource  = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ],
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = var.account_id
        }
      }
    }]
  })
}

resource "aws_s3_object" "bundle" {
  bucket = aws_s3_bucket.this.id
  key    = var.object_key
  source = var.client_ca_bundle_pem_path
  etag   = filemd5(var.client_ca_bundle_pem_path)
}
