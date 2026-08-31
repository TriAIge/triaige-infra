resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name      = "igw-triaige"
    Project   = "triaige"
    Component = "network"
    ManagedBy = "terraform"
    Environment = var.environment
  }
}
