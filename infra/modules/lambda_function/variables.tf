variable "function_name" {
  type        = string
  description = "Nome da função Lambda"
}

variable "filename" {
  type        = string
  description = "Caminho para o arquivo .zip da Lambda"
}

variable "handler" {
  type        = string
  default     = "index.handler"
  description = "Handler da Lambda"
}

variable "runtime" {
  type        = string
  default     = "nodejs18.x"
  description = "Runtime da Lambda"
}

variable "role_arn" {
  type        = string
  description = "ARN da role usada pela Lambda"
}
