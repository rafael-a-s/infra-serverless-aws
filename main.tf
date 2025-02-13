terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "./modules/vpc"
}

module "iam" {
  source  = "./modules/iam"
}

module "api_gateway" {
  source  = "./modules/api_gateway"
}

module "lambda" {
  source  = "./modules/lambda"
}

module "ecs_fargate" {
  source  = "./modules/ecs_fargate"
  vpc_id  = module.vpc.vpc_id
}

module "rds" {
  source  = "./modules/rds"
  vpc_id  = module.vpc.vpc_id
}

module "cloudwatch" {
  source  = "./modules/cloudwatch"
}

module "codepipeline" {
  source  = "./modules/codepipeline"
}
