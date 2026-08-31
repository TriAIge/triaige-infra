data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "bff_front" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.large"
  subnet_id                   = var.public_subnet_a
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_bff_front_id]
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = {
    Name        = "triaige-ec2-bff-front"
    Project     = "triaige"
    Component   = "bff-front"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_instance" "mcp" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.large"
  subnet_id                   = var.public_subnet_b
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_mcp_id]
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
  }

  tags = {
    Name        = "triaige-ec2-mcp"
    Project     = "triaige"
    Component   = "mcp"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_instance" "mysql" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.medium"
  subnet_id                   = var.private_subnet
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.sg_mysql_id]
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "triaige-ec2-mysql"
    Project     = "triaige"
    Component   = "database"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_ebs_volume" "mysql_data" {
  availability_zone = aws_instance.mysql.availability_zone
  size              = 100
  type              = "gp3"
  encrypted         = true

  tags = {
    Name        = "triaige-ebs-mysql-data"
    Project     = "triaige"
    Component   = "database"
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_volume_attachment" "mysql_data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.mysql_data.id
  instance_id = aws_instance.mysql.id
}
