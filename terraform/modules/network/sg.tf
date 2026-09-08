resource "aws_security_group" "sg_alb" {
  name        = "triaige-alb-sg"
  description = "Security group do Application Load Balancer"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-alb"
    Project     = "triaige"
    Component   = "network"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_security_group" "sg_app" {
  name        = "triaige-app-sg"
  description = "Security group das EC2 de aplicacao (orchestrator, mcp-ai, notification, frontend), replicadas nas duas AZs publicas"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "orchestrator"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  ingress {
    description     = "mcp-ai"
    from_port       = 8082
    to_port         = 8082
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  ingress {
    description     = "notification"
    from_port       = 8083
    to_port         = 8083
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  ingress {
    description     = "frontend"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  ingress {
    description = "ssh (GitHub Actions runner - IP dinamico, sem CIDR fixo)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-app"
    Project     = "triaige"
    Component   = "app"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_security_group" "sg_mysql" {
  name        = "triaige-mysql-sg"
  description = "Security group da EC2 MySQL"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "mysql from application subnets"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app.id]
  }

  ingress {
    description     = "ssh via jump host (EC2 publica, sem IP publico proprio)"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-mysql"
    Project     = "triaige"
    Component   = "database"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}
