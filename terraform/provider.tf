terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # suporta mTLS no ALB
      version = ">= 5.83.0, < 7.0.0"
    }
  }

  backend "s3" {
    bucket  = "conta-comigo-teste-tf"
    key     = "infra/main.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
