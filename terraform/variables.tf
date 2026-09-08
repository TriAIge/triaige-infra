variable "aws_region" {
  description = "Região AWS para os recursos do ambiente Triaige"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy (dev, staging ou prod)"
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "E-mail para receber notificações do SNS sobre alarmes do CloudWatch"
  type        = string
  default     = "ops@triaige.local"
}

variable "iam_instance_profile" {
  description = "Instance profile IAM existente usado pelas EC2"
  type        = string
  default     = "LabInstanceProfile"
}

variable "acm_certificate_arn" {
  description = "ARN de um certificado ACM existente para o listener HTTPS do ALB"
  type        = string
  default     = ""
}
