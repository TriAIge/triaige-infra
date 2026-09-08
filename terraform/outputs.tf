output "vpc_id" {
  description = "ID da VPC Triaige"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Subnets públicas da VPC"
  value       = module.network.public_subnet_ids
}

output "private_subnet_id" {
  description = "Subnet privada do banco de dados"
  value       = module.network.private_subnet_id
}

output "ec2_public_ips" {
  description = "IPs públicos das EC2 de aplicação"
  value       = module.ec2.ec2_public_ips
}

output "ec2_private_ip" {
  description = "IP privado da EC2 de banco de dados"
  value       = module.ec2.ec2_private_ip
}

output "alb_dns_name" {
  description = "DNS do Application Load Balancer"
  value       = module.load_balancer.alb_dns_name
}

output "s3_buckets" {
  description = "Buckets S3 criados pelo ambiente"
  value = {
    raw     = module.storage.s3_raw
    trusted = module.storage.s3_trusted
    curated = module.storage.s3_curated
  }
}

output "sqs_queues" {
  description = "URLs das filas SQS principais"
  value       = module.sqs.queue_urls
}

