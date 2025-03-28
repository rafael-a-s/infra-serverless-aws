variable "role_name" {
  type        = string
  description = "Nome da role do Lambda"
}

variable "dynamodb_table_arn" {
  type        = string
  description = "ARN da tabela DynamoDB que a Lambda poderá acessar"
}
