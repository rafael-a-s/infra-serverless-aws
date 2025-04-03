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