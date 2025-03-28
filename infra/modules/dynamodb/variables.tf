variable "table_name" {
  type        = string
  description = "Nome da tabela do DynamoDB"
}

variable "hash_key_name" {
  type        = string
  description = "Nome da chave primária"
}

variable "hash_key_type" {
  type        = string
  description = "Tipo da chave primária (S, N, B)"
  default     = "S"
}

variable "tags" {
  type        = map(string)
  description = "Tags da tabela"
  default     = {}
}
