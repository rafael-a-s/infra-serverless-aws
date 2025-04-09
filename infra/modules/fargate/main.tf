# ECS Cluster
resource "aws_ecs_cluster" "fargate_cluster" {
  name = var.cluster_name
}

resource "aws_iam_policy" "allow_dynamodb_access_pedidos" {
  name        = "AllowDynamoDBPutUpdatePedidos"
  description = "Permite que a role ECS escreva e atualize na tabela DynamoDB Pedidos"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        Resource = "arn:aws:dynamodb:us-east-1:637423576760:table/Pedidos"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_dynamodb_access_to_execution_role" {
  name       = "AttachDynamoDBAccessToExecutionRole"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.allow_dynamodb_access_pedidos.arn
}

# ECS Task Definition para o Post-Pedido com logs
resource "aws_ecs_task_definition" "post_pedido_task" {
  family                   = "post-pedido-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "post-pedido"
    image     = var.post_pedido_image
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}

# ECS Task Definition para o Put-Pedido com logs
resource "aws_ecs_task_definition" "put_pedido_task" {
  family                   = "put-pedido-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "put-pedido"
    image     = var.put_pedido_image
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}


# ECS Service para o POST Pedido - CORRIGIDO COM LOAD BALANCER
resource "aws_ecs_service" "post_pedido_service" {
  name            = "post-pedido-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.post_pedido_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  # Importante: adicionado health_check_grace_period_seconds para dar tempo ao container para inicializar
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.fargate_sg.id]  # Usando security group dedicado
    assign_public_ip = true
  }

  # IMPORTANTE: Adicionando load_balancer para registrar o serviço no target group
  load_balancer {
    target_group_arn = aws_lb_target_group.post_pedido_tg.arn
    container_name   = "post-pedido"
    container_port   = 3000
  }

  # Evitar atualizações do serviço para certos parâmetros
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.post_pedido_listener]
}

# ECS Service para o PUT Pedido - CORRIGIDO COM LOAD BALANCER
resource "aws_ecs_service" "put_pedido_service" {
  name            = "put-pedido-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.put_pedido_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  # Importante: adicionado health_check_grace_period_seconds para dar tempo ao container para inicializar
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.fargate_sg.id]  # Usando security group dedicado
    assign_public_ip = true
  }

  # IMPORTANTE: Adicionando load_balancer para registrar o serviço no target group
  load_balancer {
    target_group_arn = aws_lb_target_group.put_pedido_tg.arn
    container_name   = "put-pedido"
    container_port   = 3000
  }

  # Evitar atualizações do serviço para certos parâmetros
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.put_pedido_listener]
}

# ECS Task Execution Role com permissões para CloudWatch Logs
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

# Security Group específico para os serviços Fargate
resource "aws_security_group" "fargate_sg" {
  name        = "${var.cluster_name}-fargate-sg"
  description = "Security Group for Fargate services"
  vpc_id      = var.vpc_id

  # Ingress rule para a porta 3000
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic on port 3000"
  }

  # Importante: adicionar regra de egress para permitir tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.cluster_name}-fargate-sg"
  }
}

# Network Load Balancer (NLB) para expor os serviços Fargate
resource "aws_lb" "fargate_nlb" {
  name               = "fargate-nlb"
  internal           = false  # NLB acessível na internet
  load_balancer_type = "network"
  subnets            = var.subnets
}

# Target Group para o serviço POST com health check
resource "aws_lb_target_group" "post_pedido_tg" {
  name        = "post-pedido-tg"
  port        = 3000
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  # Health check básico
  health_check {
    protocol            = "TCP"
    port                = 3000
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }
}

# Target Group para o serviço PUT
resource "aws_lb_target_group" "put_pedido_tg" {
  name        = "put-pedido-tg"
  port        = 3001
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  # Health check básico
  health_check {
    protocol            = "TCP"
    port                = 3000
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }
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

# Attach the Amazon ECS Task Execution Role policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}