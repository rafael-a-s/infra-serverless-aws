resource "aws_ecs_cluster" "fargate_cluster" {
  name = "pedidos-cluster"
}

resource "aws_ecs_task_definition" "pedido_processing" {
  family                   = "pedido-processing"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  container_definitions    = jsonencode([{
    name      = "pedido-container"
    image     = "123456789.dkr.ecr.us-east-1.amazonaws.com/pedido-api:latest"
    cpu       = 512
    memory    = 1024
    essential = true
  }])
}