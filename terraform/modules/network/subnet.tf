resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "172.16.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-a"
    Project     = "triaige"
    Component   = "network"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-b"
    Project     = "triaige"
    Component   = "network"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "172.16.2.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false

  tags = {
    Name        = "private-subnet-c"
    Project     = "triaige"
    Component   = "network"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}
