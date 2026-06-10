resource "aws_internet_gateway" "igw-triaige" {
  vpc_id = aws_vpc.vpc-triaige.id

  tags = {
    Name = "igw-vpc-edu-invtt"
  }
}
