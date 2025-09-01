variable "vpc_cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(any)
}

variable "private_subnets" {
  type = list(any)
}

variable "customer_group" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  description = "AWS Tagging"
  type        = map(string)
  default = {
    "Environment"   = "dev"
    "Application_ID" = "vpc"
    "Application_Role" = "Abriga Endereçamento de Subnets"

  }
}