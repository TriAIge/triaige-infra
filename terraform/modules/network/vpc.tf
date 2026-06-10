resource "aws_vpc" "vpc-triaige" {
  cidr_block = "10.0.0.0/23"

  tags = {
    Name = "vpc-triaige"
  }
}
