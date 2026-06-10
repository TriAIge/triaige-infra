resource "aws_key_pair" "public_key_triaige" {
  key_name   = var.key_pair_name_public
  public_key = file("${path.root}/keys/key-ec2-public-triaige.pem.pub")
}

resource "aws_key_pair" "private_key" {
  key_name   = var.key_pair_name_private
  public_key = file("${path.root}/keys/key-ec2-private-triaige.pem.pub")
}

resource "aws_instance" "ec2_public_triaige" {
  count                       = length(var.azs)
  ami                         = "ami-0e86e20dae9224db8"
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnets[count.index]
  associate_public_ip_address = true
  security_groups             = [var.sg_public_triaige_id]
  iam_instance_profile        = "LabInstanceProfile"
  key_name                    = aws_key_pair.public_key_triaige.key_name

  tags = {
    Name = "ec2-public-triaige-${var.azs[count.index]}"
  }
}

resource "aws_instance" "ec2_private" {
  ami                         = "ami-0e86e20dae9224db8"
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet
  associate_public_ip_address = false
  security_groups             = [var.sg_private_triaige_id]
  iam_instance_profile        = "LabInstanceProfile"
  key_name                    = aws_key_pair.private_key.key_name

  tags = {
    Name = "ec2-private-banco-dados"
  }
}
