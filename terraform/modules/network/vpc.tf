resource "aws_vpc" "this" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "vpc-triaige"
    Project     = "triaige"
    Component   = "network"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}
