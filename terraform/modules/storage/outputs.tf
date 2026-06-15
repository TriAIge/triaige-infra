output "s3_raw" {
  description = "Nome do bucket S3 para os dados brutos"
  value       = aws_s3_bucket.bucket-triaige-raw-certificacoes.bucket
}

output "s3_raw_arn" {
  value = aws_s3_bucket.bucket-triaige-raw-certificacoes.arn
}

output "s3_trusted" {
  description = "Nome do bucket S3 para os dados trusted"
  value       = aws_s3_bucket.bucket-triaige-trusted-certificacoes.bucket
}

output "s3_trusted_arn" {
  value = aws_s3_bucket.bucket-triaige-trusted-certificacoes.arn
}

output "s3_curated" {
  description = "Nome do bucket S3 curated"
  value       = aws_s3_bucket.bucket-triaige-curated.bucket
}
