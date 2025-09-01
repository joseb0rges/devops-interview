module "s3_mtls" {
  source = "./modules/s3_mtls"
  app_name                   = "api"
  env                        = "dev"
  account_id                 = "573412182393"
  client_ca_bundle_pem_path  = "./certs/client-ca-bundle.pem"
  object_key                 = "client-ca-bundle.pem"
}