output "alb_dns_name" {
  description = "DNS name do alb-triaige, usado por outros serviços (ex.: callback REST da Lambda de pré-processamento) para chamar o orchestrator"
  value       = aws_lb.alb_triaige.dns_name
}

output "alb_arn" {
  description = "ARN do alb-triaige"
  value       = aws_lb.alb_triaige.arn
}
