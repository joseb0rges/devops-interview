variable "app_name"            { type = string }
variable "env"                 { type = string }
variable "internal"            { type = bool }
variable "subnet_ids_pub"      { type = list(string) }
variable "vpc_id"              { type = string }
variable "container_port"      { type = number }
variable "acm_certificate_arn" { type = string }

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

# Quem pode acessar o ALB (443)
variable "allowed_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# Listener 80 e bypass do /health
variable "enable_http_80" {
  type    = bool
  default = false
}

variable "health_bypass_on_http80" {
  type    = bool
  default = true
}

variable "health_bypass_cidrs" {
  type    = list(string)
  default = ["127.0.0.1/32"] 
}

variable "health_path" {
  type    = string
  default = "/health"
}

# mTLS
variable "mtls_mode" {
  type    = string
  default = "verify" # "verify" | "passthrough"
  validation {
    condition     = contains(["verify","passthrough"], var.mtls_mode)
    error_message = "mtls_mode deve ser 'verify' ou 'passthrough'."
  }
}

# interface booleana (mapeada para "on"/"off" no listener)
variable "advertise_ca_names" {
  type    = bool
  default = true
}

# Trust store (do módulo s3_mtls)
variable "truststore_s3_bucket"         { type = string }
variable "truststore_s3_key"            { type = string }
variable "truststore_s3_object_version" { type = string }
