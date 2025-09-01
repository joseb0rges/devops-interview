variable "app_name"  { type = string }
variable "env"       { type = string }
variable "account_id"{ type = string }

variable "client_ca_bundle_pem_path" {
  type        = string
  description = "Caminho local do bundle PEM das CAs de CLIENTE (mTLS) a ser enviado ao S3."
}

variable "object_key" {
  type    = string
  default = "client-ca-bundle.pem"
}
