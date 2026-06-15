# Lambda de pré-processamento (OCR/normalização/anonimização) do TriAIge.
#
# Recurso novo: ainda não existia representação no Terraform para a Lambda
# de pré-processamento. Código-fonte em triaige-fn-ocr-normalizer
# (lambda_function.py / extrator_juridico.py / anonimizador.py).
#
# Trigger: SQS event source mapping na fila triaige-docs-preprocessing.
# Saída: texto normalizado em bucket-triaige-trusted-certificacoes-... +
# callback REST para o triaige-srv-orchestrator
# (POST /internal/api/v1/sessions/{sessionId}/pre-processing/completed).

data "aws_iam_role" "lambda_execution_role" {
  name = var.execution_role_name
}

resource "aws_lambda_function" "ocr_normalizer" {
  function_name = var.function_name
  description   = "Pre-processamento (OCR/normalizacao/anonimizacao) de documentos juridicos para o TriAIge"

  filename         = var.lambda_package_path
  source_code_hash = filebase64sha256(var.lambda_package_path)

  runtime = var.runtime
  handler = var.handler
  role    = data.aws_iam_role.lambda_execution_role.arn

  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = {
      TRUSTED_BUCKET_NAME                   = var.trusted_bucket_name
      ORCHESTRATOR_BASE_URL                 = var.orchestrator_base_url
      ORCHESTRATOR_CALLBACK_TIMEOUT_SECONDS = tostring(var.callback_timeout_seconds)
      LOG_LEVEL                             = var.log_level
      TESSERACT_CMD                         = var.tesseract_cmd
      TESSERACT_LANGS                       = var.tesseract_langs
    }
  }

  tags = {
    Name = var.function_name
  }
}

resource "aws_lambda_event_source_mapping" "docs_preprocessing" {
  event_source_arn = var.docs_preprocessing_queue_arn
  function_name    = aws_lambda_function.ocr_normalizer.arn
  batch_size       = var.batch_size

  function_response_types = ["ReportBatchItemFailures"]
}
