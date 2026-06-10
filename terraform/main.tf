terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
}

module "storage" {
  source = "./modules/storage"
}

module "sqs" {
  source = "./modules/messaging/sqs"
}

module "ec2" {
  depends_on           = [module.network]
  source               = "./modules/compute/ec2"
  public_subnets       = module.network.public_subnet_ids
  private_subnet       = module.network.private_subnet_id
  sg_public_triaige_id = module.network.sg_public_triaige_id
  sg_private_triaige_id = module.network.sg_private_triaige_id
}

module "load_balancer" {
  depends_on             = [module.ec2, module.network]
  source                 = "./modules/load_balancer"
  vpc_id                 = module.network.vpc_id
  subnet_ids             = module.network.public_subnet_ids
  security_groups_id_alb = module.network.security_groups_id_alb
  ec2_ids_triaige        = module.ec2.ec2_ids_triaige
}
