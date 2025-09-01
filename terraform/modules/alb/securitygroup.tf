resource "aws_security_group" "alb_sg" {
  vpc_id                 = var.vpc_id
  name                   = "${var.app_name}-${var.env}-alb-sg"
  description            = "Security group for ALB"
  revoke_rules_on_delete = true

  # HTTPS 443 de quem você permitir
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidrs
  }

  # HTTP 80 (somente para bypass /health, se habilitado)
  dynamic "ingress" {
    for_each = var.enable_http_80 && var.health_bypass_on_http80 ? [1] : []
    content {
      description = "HTTP health bypass"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.health_bypass_cidrs
    }
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-${var.env}-alb-sg"
    App  = var.app_name
    Env  = var.env
  }
}
