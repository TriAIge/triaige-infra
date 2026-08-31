resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name      = "nat-triaige"
    Project   = "triaige"
    Component = "network"
    ManagedBy = "terraform"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name      = "nat-triaige"
    Project   = "triaige"
    Component = "network"
    ManagedBy = "terraform"
    Environment = var.environment
  }
}
