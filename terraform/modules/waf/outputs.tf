output "web_acl_id" {
  value       = aws_wafv2_web_acl.this.id
  description = "ID do Web ACL."
}

output "web_acl_arn" {
  value       = aws_wafv2_web_acl.this.arn
  description = "ARN do Web ACL (use no CloudFront)."
}