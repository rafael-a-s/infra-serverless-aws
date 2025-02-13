terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "meu-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
}