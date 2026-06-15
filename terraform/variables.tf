variable "lambda_ocr_normalizer_package_path" {
  description = "Caminho do pacote .zip da Lambda triaige-fn-ocr-normalizer (gerado conforme readMe.md desse repositório). Assume checkout do repositório triaige-fn-ocr-normalizer como diretório irmão de triaige-infra."
  type        = string
  default     = "../../triaige-fn-ocr-normalizer/build/triaige-fn-ocr-normalizer.zip"
}
