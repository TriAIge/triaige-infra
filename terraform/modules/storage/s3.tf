resource "aws_s3_bucket" "bucket-triaige-raw-certificacoes" {
  bucket        = "bucket-triaige-raw-certificacoes-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  force_destroy = true

  tags = {
    Name = "bucket-triaige-raw-certificacoes"
  }
}

resource "aws_s3_bucket" "bucket-triaige-trusted-certificacoes" {
  bucket        = "bucket-triaige-trusted-certificacoes-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  force_destroy = true

  tags = {
    Name = "bucket-triaige-trusted-certificacoes"
  }
}

resource "aws_s3_bucket" "bucket-triaige-curated" {
  bucket        = "bucket-triaige-curated-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  force_destroy = true

  tags = {
    Name = "bucket-triaige-curated"
  }
}
