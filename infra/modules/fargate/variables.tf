variable "subnets" {
  description = "IDs das subnets para a configuração da rede"
  type        = list(string)
}

variable "security_groups" {
  description = "IDs dos grupos de segurança"
  type        = list(string)
}

variable "cluster_name" {
  type        = string
  description = "Nome do cluster ECS"
}

variable "cpu" {
  type        = string
  description = "CPU para a task"
  default     = "256"
}

variable "memory" {
  type        = string
  description = "Memória para a task"
  default     = "512"
}

variable "post_pedido_image" {
  type        = string
  description = "URL da imagem Docker do Post Pedido no ECR"
}

variable "put_pedido_image" {
  type        = string
  description = "URL da imagem Docker do Put Pedido no ECR"
}

variable "vpc_id" {
  description = "ID da VPC onde os recursos serão implantados"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}