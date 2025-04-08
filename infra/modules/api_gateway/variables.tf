variable "api_name" {
  type        = string
  description = "Nome da API"
}

variable "api_description" {
  type        = string
  default     = ""
}

variable "lambda_get_invoke_arn" {
  type        = string
  description = "Invoke ARN da função Lambda GET"
}

variable "lambda_get_function_name" {
  type        = string
  description = "Nome da função Lambda GET"
}

variable "lambda_delete_invoke_arn" {
  type        = string
  description = "Invoke ARN da função Lambda DELETE"
}

variable "lambda_delete_function_name" {
  type        = string
  description = "Nome da função Lambda DELETE"
}

variable "region" {
  type        = string
  description = "Região AWS para compor a URL do endpoint"
}

variable "nlb_arn" {
  description = "ARN do NLB para o VPC Link"
  type        = string
}

variable "nlb_dns_name" {
  description = "DNS do NLB"
  type        = string
}

