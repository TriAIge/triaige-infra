# Os buckets NÃO são criados pelo Terraform: a SCP da role de estudante
# nega s3:GetBucketObjectLockConfiguration, que o provider AWS chama ao
# criar/ler um aws_s3_bucket. Os buckets são criados manualmente e aqui
# apenas montamos os nomes (hard coded + nome do integrante).
#
# Também não usamos data "aws_s3_bucket" para não depender de chamadas de
# leitura na API do S3 — o ARN de bucket é determinístico pelo nome.
locals {
  bucket_raw     = "bucket-triaige-raw-sptech-${var.integrante}"
  bucket_trusted = "bucket-triaige-trusted-sptech-${var.integrante}"
  bucket_curated = "bucket-triaige-curated-sptech-${var.integrante}"
}
