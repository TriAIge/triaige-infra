variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "Subnets públicas para cada AZ"
  type        = list(string)
}

variable "private_subnet" {
  description = "Id subnet privada"
  type        = string
}

variable "sg_public_triaige_id" {
  description = "ID do security group da instancia publica TriAige"
  type        = string
}

variable "sg_private_triaige_id" {
  description = "ID do security group privado"
  type        = string
}

variable "key_pair_name_public" {
  type    = string
  default = "key-ec2-public-triaige"
}

variable "key_pair_name_private" {
  type    = string
  default = "key-ec2-private-triaige"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default = "t3.small"
}
