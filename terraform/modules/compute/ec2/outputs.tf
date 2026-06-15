output "ec2_ids_triaige" {
  description = "IDs das EC2 publicas TriAige"
  value = aws_instance.ec2_public_triaige[*].id
}

output "ec2_public_ips" {
  description = "IPs publicos das EC2 publicas TriAige (mesma ordem de var.azs)"
  value       = aws_instance.ec2_public_triaige[*].public_ip
}

output "ec2_private_ip" {
  description = "IP privado da EC2 ec2-private-banco-dados"
  value       = aws_instance.ec2_private.private_ip
}
