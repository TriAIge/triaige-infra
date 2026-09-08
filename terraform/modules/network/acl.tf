resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.this.id

  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 8080
    to_port    = 8080
    cidr_block = "172.16.0.0/16"
  }

  ingress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 8082
    to_port    = 8082
    cidr_block = "172.16.0.0/16"
  }

  ingress {
    rule_no    = 130
    action     = "allow"
    protocol   = "tcp"
    from_port  = 8083
    to_port    = 8083
    cidr_block = "172.16.0.0/16"
  }

  ingress {
    rule_no    = 140
    action     = "allow"
    protocol   = "tcp"
    from_port  = 3000
    to_port    = 3000
    cidr_block = "172.16.0.0/16"
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name        = "nacl-public-triaige"
    Project     = "triaige"
    Component   = "network"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.this.id

  subnet_ids = [aws_subnet.private_c.id]

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 3306
    to_port    = 3306
    cidr_block = "172.16.0.0/24"
  }

  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 3306
    to_port    = 3306
    cidr_block = "172.16.1.0/24"
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 3306
    to_port    = 3306
    cidr_block = "172.16.0.0/16"
  }

  tags = {
    Name        = "nacl-private-triaige"
    Project     = "triaige"
    Component   = "network"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}
