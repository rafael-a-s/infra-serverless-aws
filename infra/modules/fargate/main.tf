# ECS Cluster
resource "aws_ecs_cluster" "fargate_cluster" {
  name = var.cluster_name
}

# ECS Task Definition para o Post-Pedido
resource "aws_ecs_task_definition" "post_pedido_task" {
  family                   = "post-pedido-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "post-pedido"
    image     = var.post_pedido_image
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}

# ECS Task Definition para o Put-Pedido
resource "aws_ecs_task_definition" "put_pedido_task" {
  family                   = "put-pedido-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "put-pedido"
    image     = var.put_pedido_image
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}

# ECS Service para o POST Pedido
resource "aws_ecs_service" "post_pedido_service" {
  name            = "post-pedido-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.post_pedido_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }
}

# ECS Service para o PUT Pedido
resource "aws_ecs_service" "put_pedido_service" {
  name            = "put-pedido-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.put_pedido_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Network Load Balancer (NLB) para expor os serviços Fargate
resource "aws_lb" "fargate_nlb" {
  name               = "fargate-nlb"
  internal           = false  # NLB acessível na internet
  load_balancer_type = "network"
  subnets            = var.subnets
}

# Target Group para o serviço POST
resource "aws_lb_target_group" "post_pedido_tg" {
  name        = "post-pedido-tg"
  port        = 3000
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

# Target Group para o serviço PUT
resource "aws_lb_target_group" "put_pedido_tg" {
  name        = "put-pedido-tg"
  port        = 3001
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

# Listener para o POST
resource "aws_lb_listener" "post_pedido_listener" {
  load_balancer_arn = aws_lb.fargate_nlb.arn
  port              = 3000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.post_pedido_tg.arn
  }
}

# Listener para o PUT
resource "aws_lb_listener" "put_pedido_listener" {
  load_balancer_arn = aws_lb.fargate_nlb.arn
  port              = 3001
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.put_pedido_tg.arn
  }
}

# Obtendo o Security Group padrão da VPC
data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

# Adicionando a regra para permitir tráfego na porta 3000
resource "aws_security_group_rule" "allow_tcp_3000" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]  # Permitindo acesso de qualquer IP
  security_group_id       = data.aws_security_group.default.id
}

# Adicionando a regra para permitir tráfego na porta 3001
resource "aws_security_group_rule" "allow_tcp_3001" {
  type                     = "ingress"
  from_port                = 3001
  to_port                  = 3001
  protocol                 = "tcp"
  cidr_blocks             = ["0.0.0.0/0"]  # Permitindo acesso de qualquer IP
  security_group_id       = data.aws_security_group.default.id
}

# Attach the Amazon ECS Task Execution Role policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}