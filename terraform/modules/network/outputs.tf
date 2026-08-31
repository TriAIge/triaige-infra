output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "public_subnet_a_id" {
  description = "ID da subnet pública A"
  value       = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "ID da subnet pública B"
  value       = aws_subnet.public_b.id
}

output "private_subnet_id" {
  description = "ID da subnet privada"
  value       = aws_subnet.private_c.id
}

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.this.id
}

output "sg_bff_front_id" {
  description = "ID do SG do EC2 BFF/Frontend"
  value       = aws_security_group.sg_bff_front.id
}

output "sg_mcp_id" {
  description = "ID do SG do EC2 MCP"
  value       = aws_security_group.sg_mcp.id
}

output "sg_mysql_id" {
  description = "ID do SG do EC2 MySQL"
  value       = aws_security_group.sg_mysql.id
}

output "sg_alb_id" {
  description = "ID do SG do ALB"
  value       = aws_security_group.sg_alb.id
}
