output "fargate_cluster_id" {
  value = aws_ecs_cluster.fargate_cluster.id
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "post_pedido_service_name" {
  value = aws_ecs_service.post_pedido_service.name
}

output "put_pedido_service_name" {
  value = aws_ecs_service.put_pedido_service.name
}

# Expondo o DNS do NLB para acessar os métodos
output "nlb_dns_name" {
  value = aws_lb.fargate_nlb.dns_name
  description = "DNS do Network Load Balancer"
}

# Expondo o ARN do Load Balancer para futuras referências
output "nlb_arn" {
  value = aws_lb.fargate_nlb.arn
  description = "ARN do Network Load Balancer"
}

output "fargate_nlb_arn" {
  value = aws_lb.fargate_nlb.arn
}

output "fargate_nlb_dns_name" {
  value = aws_lb.fargate_nlb.dns_name
}
