resource "aws_alb" "this" {
  name               = "${var.app_name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.subnet_ids_pub
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name = "${var.app_name}-${var.env}-alb"
    App  = var.app_name
    Env  = var.env
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.app_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = var.health_path
    protocol            = "HTTP"
    matcher             = "200-399"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
  }

  tags = {
    Name = "${var.app_name}-${var.env}-tg"
    App  = var.app_name
    Env  = var.env
  }
}

# Listener HTTP:80 (criado somente quando enable_http_80 = true)
resource "aws_lb_listener" "http_80" {
  count             = var.enable_http_80 ? 1 : 0
  load_balancer_arn = aws_alb.this.arn
  port              = 80
  protocol          = "HTTP"

  # default: redirect -> 443
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Regra /health no 80 (bypass antes do redirect)
resource "aws_lb_listener_rule" "http80_health_forward" {
  count        = var.enable_http_80 && var.health_bypass_on_http80 ? 1 : 0
  listener_arn = aws_lb_listener.http_80[0].arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern { values = [var.health_path] }
  }
}

# Trust Store (apenas no verify)
resource "aws_lb_trust_store" "mtls" {
  count = var.mtls_mode == "verify" ? 1 : 0

  ca_certificates_bundle_s3_bucket         = var.truststore_s3_bucket
  ca_certificates_bundle_s3_key            = var.truststore_s3_key
  ca_certificates_bundle_s3_object_version = var.truststore_s3_object_version
}

locals {
  trust_store_arn = var.mtls_mode == "verify" ? aws_lb_trust_store.mtls[0].arn : null
}

# Listener HTTPS:443 com mTLS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.acm_certificate_arn

  mutual_authentication {
    mode                           = var.mtls_mode                                
    trust_store_arn                = local.trust_store_arn                       
    advertise_trust_store_ca_names = var.advertise_ca_names ? "on" : "off"
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
