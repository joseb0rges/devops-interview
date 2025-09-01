variable "default_tags" {
  type = map
  default = {
    Application = "conta-comigo"
    Environment = "Dev"
  }
}

variable "region" {
  default = "us-east-1"
}

variable "tls_certificate_arn" {
  default = "arn:aws:acm:us-east-1:573412182393:certificate/d2037dfa-1c41-4bc6-bd74-bb304d24198e"
}
