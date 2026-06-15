output "ec2_ids_triaige" {
  description = "IDs das EC2 publicas TriAige"
  value = aws_instance.ec2_public_triaige[*].id
}
