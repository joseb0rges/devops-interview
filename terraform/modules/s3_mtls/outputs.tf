output "bucket" {
  value = aws_s3_bucket.this.bucket
}
output "object_key" {
  value = aws_s3_object.bundle.key
}
output "object_version" {
  value = aws_s3_object.bundle.version_id
}
