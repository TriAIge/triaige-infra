output "function_name" {
  description = "Nome da função Lambda triaige-fn-ocr-normalizer"
  value       = aws_lambda_function.ocr_normalizer.function_name
}

output "function_arn" {
  description = "ARN da função Lambda triaige-fn-ocr-normalizer"
  value       = aws_lambda_function.ocr_normalizer.arn
}

output "event_source_mapping_id" {
  description = "ID do event source mapping entre triaige-docs-preprocessing e a Lambda"
  value       = aws_lambda_event_source_mapping.docs_preprocessing.id
}
