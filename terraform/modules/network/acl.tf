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

  # SSH direto (GitHub Actions runner / maquina local, sem CIDR fixo -
  # mesma logica do sg_app). NACL e stateless, entao isso e independente da
  # regra de SG - sem esta entrada, o SG ate libera mas o pacote nunca chega.
  ingress {
    rule_no    = 150
    action     = "allow"
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_block = "0.0.0.0/0"
  }

  # Retorno do SSH que a EC2 publica abre para a EC2 privada via ProxyJump
  # (ec2-private-banco-dados respondendo na porta efemera de quem iniciou).
  ingress {
    rule_no    = 160
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "172.16.2.0/24"
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

  # SSH via jump host (ProxyJump pelas EC2 publicas - a EC2 privada nao tem
  # IP publico, entao so e alcancavel a partir da propria VPC).
  ingress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_block = "172.16.0.0/24"
  }

  ingress {
    rule_no    = 130
    action     = "allow"
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
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

  # Retorno do SSH recebido via ProxyJump (resposta pra porta efemera de
  # quem conectou, a partir de uma das EC2 publicas).
  egress {
    rule_no    = 130
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
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
