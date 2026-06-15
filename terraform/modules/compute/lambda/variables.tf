variable "function_name" {
  description = "Nome da função Lambda"
  type        = string
  default     = "triaige-fn-ocr-normalizer"
}

variable "lambda_package_path" {
  description = "Caminho do pacote .zip da função, gerado conforme o readMe.md de triaige-fn-ocr-normalizer (lambda_function.py + extrator_juridico.py + anonimizador.py + dependências)."
  type        = string
}

variable "runtime" {
  description = "Runtime da Lambda"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Handler da Lambda (módulo.função)"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "timeout" {
  description = "Timeout da Lambda, em segundos. Deve ser menor que o visibility_timeout da fila triaige-docs-preprocessing (300s)."
  type        = number
  default     = 120
}

variable "memory_size" {
  description = "Memória alocada para a Lambda, em MB"
  type        = number
  default     = 512
}

variable "execution_role_name" {
  description = "Nome do IAM role existente usado como execution role da Lambda (no ambiente de laboratório atual, o role disponível é LabRole, mesmo padrão usado em LabInstanceProfile para as EC2)."
  type        = string
  default     = "LabRole"
}

variable "docs_preprocessing_queue_arn" {
  description = "ARN da fila SQS triaige-docs-preprocessing (output queue_arns do módulo sqs), usada como trigger da Lambda via event source mapping"
  type        = string
}

variable "batch_size" {
  description = "Quantidade máxima de mensagens SQS por invocação da Lambda"
  type        = number
  default     = 1
}

variable "trusted_bucket_name" {
  description = "Nome do bucket S3 trusted (output s3_trusted do módulo storage), onde o texto normalizado é gravado"
  type        = string
}

variable "orchestrator_base_url" {
  description = "URL base do triaige-srv-orchestrator, usada pela Lambda para o callback REST de pré-processamento concluído (ex.: http://<dns do alb-triaige>)"
  type        = string
}

variable "log_level" {
  description = "Nível de log da Lambda"
  type        = string
  default     = "INFO"
}

variable "tesseract_cmd" {
  description = "Caminho do binário tesseract (relevante apenas se uma Lambda Layer com Tesseract for adicionada)"
  type        = string
  default     = "tesseract"
}

variable "tesseract_langs" {
  description = "Idiomas usados pelo Tesseract"
  type        = string
  default     = "por+eng"
}

variable "callback_timeout_seconds" {
  description = "Timeout, em segundos, do callback REST para o orchestrator"
  type        = number
  default     = 10
}
