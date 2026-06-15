# Outputs usados pelo workflow de deploy (Ansible) para subir os servicos
# triaige-srv-ai e triaige-srv-orchestrator nas EC2 publicas apos o apply.

output "ec2_public_ips" {
  description = "IPs publicos das EC2 publicas TriAige (us-east-1a, us-east-1b), usados pelo inventario do Ansible"
  value       = module.ec2.ec2_public_ips
}

output "ec2_private_ip" {
  description = "IP privado da EC2 ec2-private-banco-dados, usado como host MySQL por triaige-srv-orchestrator (perfil prod)"
  value       = module.ec2.ec2_private_ip
}

output "s3_raw" {
  description = "Nome do bucket S3 raw, usado como RAW_DOCUMENTS_BUCKET por triaige-srv-orchestrator (perfil prod)"
  value       = module.storage.s3_raw
}

output "s3_curated" {
  description = "Nome do bucket S3 curated, usado como CURATED_RESULTS_BUCKET por triaige-srv-orchestrator (perfil prod)"
  value       = module.storage.s3_curated
}

output "queue_urls" {
  description = "URLs das filas SQS principais, usadas por triaige-srv-orchestrator (perfil prod)"
  value       = module.sqs.queue_urls
}

output "alb_dns_name" {
  description = "DNS name do alb-triaige"
  value       = module.load_balancer.alb_dns_name
}
