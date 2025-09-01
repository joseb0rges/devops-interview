module "alb" {
  source = "./modules/alb"
  app_name            = "api"
  env                 = "dev"
  internal            = false
  subnet_ids_pub      = module.networking.public_subnet_ids
  vpc_id              = module.networking.vpc_id
  container_port      = 5000
  # Seu certificado de SERVIDOR (domínio) no ACM (mesma região do ALB)
  acm_certificate_arn = var.tls_certificate_arn
  # TLS policy opcional
  ssl_policy          = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  # não cria listener 80
  enable_http_80      = true
  # CIDRs liberados (opcional)
  allowed_ingress_cidrs = ["0.0.0.0/0"]
  health_bypass_on_http80 = true
  health_bypass_cidrs     = ["0.0.0.0/0"]  # restrinja quem pode bater no 80
  health_path             = "/health"      # path que vai pro TG sem mTLS
  # mTLS
  mtls_mode                 = "verify"     # "verify"
  advertise_ca_names        = true
  truststore_s3_bucket      = module.s3_mtls.bucket
  truststore_s3_key         = module.s3_mtls.object_key
  truststore_s3_object_version = null
   
  depends_on = [module.s3_mtls]
}