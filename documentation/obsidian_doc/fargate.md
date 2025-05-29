## 📁 Estrutura do Módulo Fargate
O módulo Fargate (`infra/modules/fargate`) é responsável por criar uma infraestrutura de containers serverless usando AWS ECS Fargate para hospedar os serviços de POST e PUT de pedidos.
## 🏗️ Componentes Principais
### **1. ECS Cluster**
``` terraform
resource "aws_ecs_cluster" "fargate_cluster" {
  name = var.cluster_name
}
```
**Funcionalidade:**
- Cria um cluster ECS para executar os serviços Fargate
- Serve como agrupamento lógico para as tasks e serviços

### **2. Task Definitions (Definições de Tarefas)**
#### **POST Pedido Task Definition**
``` terraform
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
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/aws/ecs/${var.cluster_name}/post-pedido-service"
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "post-pedido"
      }
    }
  }])
}
```
#### **PUT Pedido Task Definition**
``` terraform
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

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/aws/ecs/${var.cluster_name}/put-pedido-service"
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "put-pedido"
      }
    }
  }])
}
```
**Funcionalidades das Task Definitions:**
- Define especificações dos containers (CPU, memória, imagem)
- Configura logging para CloudWatch
- Mapeia portas dos containers
- Associa IAM roles para permissões

### **3. ECS Services (Serviços)**
#### **POST Pedido Service**
``` terraform
resource "aws_ecs_service" "post_pedido_service" {
  name            = "post-pedido-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.post_pedido_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.fargate_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.post_pedido_tg.arn
    container_name   = "post-pedido"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.post_pedido_listener]
}
```
#### **PUT Pedido Service**
``` terraform
resource "aws_ecs_service" "put_pedido_service" {
  name            = "put-pedido-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.put_pedido_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.fargate_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.put_pedido_tg.arn
    container_name   = "put-pedido"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.put_pedido_listener]
}
```
**Funcionalidades dos Services:**
- Mantém o número desejado de tasks executando
- Configura rede e security groups
- Integra com o Load Balancer
- Define health checks e período de graça

### **4. Network Load Balancer (NLB)**
#### **Load Balancer Principal**
``` terraform
resource "aws_lb" "fargate_nlb" {
  name               = "fargate-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnets
}
```
#### **Target Groups**
``` terraform
# Target Group para POST
resource "aws_lb_target_group" "post_pedido_tg" {
  name        = "post-pedido-tg"
  port        = 3000
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    port                = 3000
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }
}

# Target Group para PUT
resource "aws_lb_target_group" "put_pedido_tg" {
  name        = "put-pedido-tg"
  port        = 3001
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    port                = 3000
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }
}
```
#### **Listeners**
``` terraform
# Listener para POST (porta 3000)
resource "aws_lb_listener" "post_pedido_listener" {
  load_balancer_arn = aws_lb.fargate_nlb.arn
  port              = 3000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.post_pedido_tg.arn
  }
}

# Listener para PUT (porta 3001)
resource "aws_lb_listener" "put_pedido_listener" {
  load_balancer_arn = aws_lb.fargate_nlb.arn
  port              = 3001
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.put_pedido_tg.arn
  }
}
```
**Funcionalidades do NLB:**
- Distribui tráfego entre containers
- Health checks automáticos
- Exposição pública dos serviços
- Separação de tráfego por porta (3000 para POST, 3001 para PUT)

### **5. IAM Roles e Políticas**
#### **ECS Task Execution Role**
``` terraform
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
```
#### **Política de Acesso ao DynamoDB**
``` terraform
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
```
**Funcionalidades das IAM Roles:**
- Permite que containers acessem serviços AWS
- Permissões específicas para DynamoDB (PUT e UPDATE)
- Acesso aos logs do CloudWatch
- Princípio de menor privilégio

### **6. Security Group**
``` terraform
resource "aws_security_group" "fargate_sg" {
  name        = "${var.cluster_name}-fargate-sg"
  description = "Security Group for Fargate services"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic on port 3000"
  }

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
```
## 📝 Variáveis do Módulo
### **variables.tf**
``` terraform
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
```
## 📤 Outputs do Módulo
### **outputs.tf**
``` terraform
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

output "nlb_dns_name" {
  value = aws_lb.fargate_nlb.dns_name
  description = "DNS do Network Load Balancer"
}

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
```
## 🔧 Configuração no main.tf Principal
``` terraform
module "fargate_post_pedido" {
  source              = "./modules/fargate"
  cluster_name        = "fargate-cluster"
  post_pedido_image   = "637423576760.dkr.ecr.us-east-1.amazonaws.com/post-pedido:latest"
  put_pedido_image    = "637423576760.dkr.ecr.us-east-1.amazonaws.com/put-pedido:latest"
  
  subnets             = ["subnet-09d66670545f16a07"]
  security_groups     = ["sg-0673c87a97e88ad2f"]
  vpc_id              = "vpc-03712270d4a22c15f"
}
```
## 🎯 Características Técnicas
### **Recursos de CPU e Memória:**
- **CPU**: 256 units (0.25 vCPU) - configurável
- **Memória**: 512 MB - configurável
- Otimizado para workloads leves de API

### **Networking:**
- **Modo de rede**: awsvpc (cada task tem seu próprio ENI)
- **IP Público**: Habilitado para acesso à internet
- **Portas**: 3000 para POST, 3001 para PUT no NLB

### **Health Checks:**
- **Protocolo**: TCP
- **Intervalo**: 30 segundos
- **Limites**: 3 checks saudáveis/não saudáveis
- **Período de graça**: 60 segundos

### **Logging:**
- **Driver**: awslogs (CloudWatch)
- **Grupos de log**: Separados por serviço
- **Prefixos**: post-pedido e put-pedido

## 🔗 Integração com Outros Módulos
### **Dependências:**
- **VPC e Subnets**: Infraestrutura de rede existente
- **DynamoDB**: Para persistência de dados
- **CloudWatch**: Para logs e monitoramento
- **API Gateway**: Para exposição pública via VPC Link

### **Outputs Utilizados por:**
- **API Gateway**: `nlb_arn` e `nlb_dns_name` para VPC Link
- **CloudWatch**: `fargate_cluster_id` para monitoramento
- **Main**: `fargate_cluster_id` para referência

## 💡 Vantagens da Arquitetura
1. **Serverless**: Não há necessidade de gerenciar instâncias EC2
2. **Escalabilidade**: Auto-scaling baseado em demanda
3. **Isolamento**: Cada serviço em container separado
4. **Health Checks**: Recuperação automática de falhas
5. **Load Balancing**: Distribuição automática de carga
6. **Logs Centralizados**: Monitoramento unificado no CloudWatch
