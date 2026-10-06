output "s3_raw" {
  description = "Nome do bucket S3 para os dados brutos"
  value       = local.bucket_raw
}

output "s3_raw_arn" {
  value = "arn:aws:s3:::${local.bucket_raw}"
}

output "s3_trusted" {
  description = "Nome do bucket S3 para os dados trusted"
  value       = local.bucket_trusted
}

output "s3_trusted_arn" {
  value = "arn:aws:s3:::${local.bucket_trusted}"
}

output "s3_curated" {
  description = "Nome do bucket S3 curated"
  value       = local.bucket_curated
}
