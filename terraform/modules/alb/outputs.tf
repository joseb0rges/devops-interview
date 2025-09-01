output "alb_arn"          { value = aws_alb.this.arn }
output "alb_dns_name"     { value = aws_alb.this.dns_name }
output "security_group_id"{ value = aws_security_group.alb_sg.id }
output "target_group_arn" { value = aws_lb_target_group.this.arn }
output "listener_https_arn" { value = aws_lb_listener.https.arn }
output "trust_store_arn"  { value = try(aws_lb_trust_store.mtls[0].arn, null) }

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "Alias do SG do ALB (compatibilidade)"
}

output "listener" {
  value       = aws_lb_listener.https.arn
  description = "Alias do listener HTTPS (443)"
}

output "listener_http_arn" {
  value       = try(aws_lb_listener.http_80[0].arn, null)
  description = "ARN do listener HTTP 80 (útil para regras /health)"
}