variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_username" {
  description = "Usuário do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "ecs_cluster_name" {
  description = "Nome do cluster ECS Fargate"
  type        = string
  default     = "pedidos-cluster"
}

variable "enable_rds" {
  description = "Define se o RDS será provisionado"
  type        = bool
  default     = true
}
