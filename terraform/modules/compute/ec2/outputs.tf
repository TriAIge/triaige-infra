output "bff_front_instance_id" {
  description = "ID da EC2 BFF/Frontend"
  value       = aws_instance.bff_front.id
}

output "mcp_instance_id" {
  description = "ID da EC2 MCP"
  value       = aws_instance.mcp.id
}

output "mysql_instance_id" {
  description = "ID da EC2 MySQL"
  value       = aws_instance.mysql.id
}

output "ec2_public_ips" {
  description = "IPs públicos das EC2 públicas do ambiente"
  value = {
    bff_front = aws_instance.bff_front.public_ip
    mcp       = aws_instance.mcp.public_ip
  }
}

output "ec2_private_ip" {
  description = "IP privado da EC2 MySQL"
  value       = aws_instance.mysql.private_ip
}
