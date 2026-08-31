variable "environment" {
  description = "Ambiente do deploy"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "iam_instance_profile" {
  description = "Instance profile IAM existente para as EC2. O padrão atende ao AWS Academy Learner Lab."
  type        = string
  default     = "LabInstanceProfile"
}

variable "public_subnet_a" {
  description = "Subnet pública da AZ us-east-1a"
  type        = string
}

variable "public_subnet_b" {
  description = "Subnet pública da AZ us-east-1b"
  type        = string
}

variable "private_subnet" {
  description = "Subnet privada da AZ us-east-1c"
  type        = string
}

variable "sg_bff_front_id" {
  description = "Security group da EC2 BFF/Frontend"
  type        = string
}

variable "sg_mcp_id" {
  description = "Security group da EC2 MCP"
  type        = string
}

variable "sg_mysql_id" {
  description = "Security group da EC2 MySQL"
  type        = string
}
