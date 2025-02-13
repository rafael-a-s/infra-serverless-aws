output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}

output "lambda_arn" {
  description = "ARN da função Lambda principal"
  value       = module.lambda.lambda_arn
}

output "api_gateway_url" {
  description = "URL base da API Gateway"
  value       = module.api_gateway.invoke_url
}

output "ecs_cluster_id" {
  description = "ID do Cluster ECS Fargate"
  value       = module.ecs_fargate.cluster_id
}

output "rds_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = module.rds.rds_endpoint
  sensitive   = true
}