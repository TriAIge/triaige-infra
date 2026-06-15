output "queue_urls" {
  description = "URLs das filas SQS principais"
  value       = { for name, queue in aws_sqs_queue.main : name => queue.url }
}

output "queue_arns" {
  description = "ARNs das filas SQS principais"
  value       = { for name, queue in aws_sqs_queue.main : name => queue.arn }
}

output "dlq_urls" {
  description = "URLs das filas DLQ"
  value       = { for name, queue in aws_sqs_queue.dlq : name => queue.url }
}

output "dlq_arns" {
  description = "ARNs das filas DLQ"
  value       = { for name, queue in aws_sqs_queue.dlq : name => queue.arn }
}
