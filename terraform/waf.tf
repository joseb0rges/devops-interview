data "aws_lb_listener" "ds_listener" {
  arn      = module.alb.listener_http_arn
}
module "waf_rules_default" {
  source = "./modules/waf/rules"  
}
module "waf_min_alb" {
  source = "./modules/waf"
  name  = "alb-waf-min-dev"
  scope = "REGIONAL"
  # associa ao ALB (já extraído do listener)
  associate_resource_arns = [
    data.aws_lb_listener.ds_listener.load_balancer_arn
  ]
  # >>> habilita as regras padrão (Managed Rule Groups)
  managed_rule_groups = module.waf_rules_default.waf_managed_default
  # Custom (as 5 regras pedidas)
  custom_rules = module.waf_rules_default.waf_custom_default
  # RateLimit = "RateLimitExceeded" na prioridade 3 com limite 1000
  rate_limit_name     = module.waf_rules_default.waf_rate_limit_name
  rate_limit          = module.waf_rules_default.waf_rate_limit_value
  rate_limit_priority = module.waf_rules_default.waf_rate_limit_priority
  tags = { Env = "dev" }
}