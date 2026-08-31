terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "triaige"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

module "network" {
  source      = "./modules/network"
  environment = var.environment
}

module "storage" {
  source = "./modules/storage"
}

module "sqs" {
  source = "./modules/messaging/sqs"
}

module "ec2" {
  source = "./modules/compute/ec2"

  aws_region           = var.aws_region
  environment          = var.environment
  iam_instance_profile = var.iam_instance_profile
  public_subnet_a      = module.network.public_subnet_a_id
  public_subnet_b      = module.network.public_subnet_b_id
  private_subnet       = module.network.private_subnet_id
  sg_bff_front_id      = module.network.sg_bff_front_id
  sg_mcp_id            = module.network.sg_mcp_id
  sg_mysql_id          = module.network.sg_mysql_id
}

module "load_balancer" {
  source = "./modules/load_balancer"

  vpc_id                 = module.network.vpc_id
  subnet_ids             = module.network.public_subnet_ids
  security_groups_id_alb = [module.network.sg_alb_id]
  ec2_ids_triaige        = [module.ec2.bff_front_instance_id, module.ec2.mcp_instance_id]
  acm_certificate_arn    = var.acm_certificate_arn
}
