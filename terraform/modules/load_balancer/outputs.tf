output "alb_dns_name" {
  description = "DNS name do alb-triaige, usado pelos serviços internos para chamar o orchestrator"
  value       = aws_lb.alb_triaige.dns_name
}

output "alb_arn" {
  description = "ARN do alb-triaige"
  value       = aws_lb.alb_triaige.arn
}
