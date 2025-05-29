## 📁 Estrutura do Módulo CloudWatch
O módulo CloudWatch (`infra/modules/cloudwatch`) é responsável por criar e configurar o sistema de monitoramento, logs e observabilidade para toda a infraestrutura do sistema de gerenciamento de pedidos.
## 🎯 Objetivo Principal
Este módulo centraliza a configuração de monitoramento para:
- **API Gateway**: Logs de requisições e respostas
- **Lambda Functions**: Logs de execução e métricas
- **ECS Fargate**: Logs de containers e métricas de CPU
- **Alarmes**: Detecção de problemas automatizada
- **Dashboards**: Visualização unificada de métricas

## 🏗️ Componentes Principais
### **1. Grupos de Logs (Log Groups)**
#### **API Gateway Log Group**
``` terraform
resource "aws_cloudwatch_log_group" "api_gateway" {
  count             = var.enable_api_gateway_logs ? 1 : 0
  name              = "/aws/apigateway/${var.api_gateway_name}"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    var.tags,
    {
      Name = "API-Gateway-Logs-${var.api_gateway_name}"
    }
  )
}
```
**Funcionalidades:**
- Logs de todas as requisições HTTP ao API Gateway
- Configuração condicional (pode ser desabilitado)
- Retenção configurável (padrão: 3 dias para economia)
- Nomenclatura padronizada: `/aws/apigateway/{nome-da-api}`

#### **Lambda Log Groups**
``` terraform
resource "aws_cloudwatch_log_group" "lambda" {
  for_each          = var.enable_lambda_logs ? toset(var.lambda_function_names) : []
  name              = "/aws/lambda/${each.value}"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    var.tags,
    {
      Name = "Lambda-Logs-${each.value}"
    }
  )
}
```
**Funcionalidades:**
- Um grupo de log para cada função Lambda
- Criação dinâmica baseada na lista de funções
- Logs de execução, erros e debug das funções
- Nomenclatura padrão AWS: `/aws/lambda/{nome-da-funcao}`

#### **Fargate Log Groups**
``` terraform
resource "aws_cloudwatch_log_group" "fargate" {
  for_each          = var.enable_fargate_logs ? toset(var.fargate_service_names) : []
  name              = "/aws/ecs/${element(split("/", var.fargate_cluster_name), length(split("/", var.fargate_cluster_name)) - 1)}/${each.value}"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    var.tags,
    {
      Name = "Fargate-Logs-${each.value}"
    }
  )
}
```
**Funcionalidades:**
- Um grupo de log para cada serviço Fargate
- Logs de aplicações executando nos containers
- Nomenclatura: `/aws/ecs/{cluster-name}/{service-name}`
- Processamento inteligente do nome do cluster

### **2. Alarmes CloudWatch**
#### **Alarme de Erros 5XX do API Gateway**
``` terraform
resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx" {
  count               = var.enable_api_gateway_logs && var.create_basic_alarms ? 1 : 0
  alarm_name          = "${var.api_gateway_name}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This alarm monitors for API Gateway 5XX errors"
  
  dimensions = {
    ApiName = var.api_gateway_name
    Stage   = var.api_gateway_stage
  }
}
```
**Características do Alarme:**
- **Métrica**: Erros 5XX (erros de servidor)
- **Limite**: Mais de 5 erros em 5 minutos
- **Período**: 300 segundos (5 minutos)
- **Avaliação**: 1 período para disparar
- **Escopo**: API Gateway específico e stage

### **3. Dashboard CloudWatch**
#### **Dashboard Principal**
``` terraform
resource "aws_cloudwatch_dashboard" "main" {
  count          = var.create_dashboard ? 1 : 0
  dashboard_name = var.dashboard_name
  
  dashboard_body = jsonencode({
    widgets = concat(
      # API Gateway widget
      var.enable_api_gateway_logs ? [{
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_gateway_name, "Stage", var.api_gateway_stage],
            [".", "4XXError", ".", ".", ".", "."],
            [".", "5XXError", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "API Gateway Metrics"
        }
      }] : [],
      
      # Lambda widget
      var.enable_lambda_logs && length(var.lambda_function_names) > 0 ? [{
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            for i, name in var.lambda_function_names : 
              ["AWS/Lambda", "Invocations", "FunctionName", name]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "Lambda Invocations"
        }
      }] : [],
      
      # Fargate widget
      var.enable_fargate_logs && length(var.fargate_service_names) > 0 ? [{
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            for i, name in var.fargate_service_names :
              ["AWS/ECS", "CPUUtilization", "ServiceName", name, "ClusterName", var.fargate_cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Fargate CPU Utilization"
        }
      }] : []
    )
  })
}
```
**Widgets do Dashboard:**

| Widget | Métricas | Posição | Funcionalidade |
| --- | --- | --- | --- |
| **API Gateway** | Count, 4XXError, 5XXError | (0,0) 12x6 | Monitoramento de requisições e erros |
| **Lambda** | Invocations | (0,6) 12x6 | Invocações de todas as funções |
| **Fargate** | CPUUtilization | (12,0) 12x6 | Utilização de CPU dos containers |
## 📝 Variáveis do Módulo
### **variables.tf**
#### **Configurações Gerais**
``` terraform
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```
#### **Configurações do API Gateway**
``` terraform
variable "enable_api_gateway_logs" {
  description = "Enable CloudWatch logs for API Gateway"
  type        = bool
  default     = true
}

variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = ""
}

variable "api_gateway_stage" {
  description = "API Gateway deployment stage"
  type        = string
  default     = "dev"
}
```
#### **Configurações do Lambda**
``` terraform
variable "enable_lambda_logs" {
  description = "Enable CloudWatch logs for Lambda functions"
  type        = bool
  default     = true
}

variable "lambda_function_names" {
  description = "List of Lambda function names"
  type        = list(string)
  default     = []
}
```
#### **Configurações do Fargate**
``` terraform
variable "enable_fargate_logs" {
  description = "Enable CloudWatch logs for ECS Fargate services"
  type        = bool
  default     = true
}

variable "fargate_cluster_name" {
  description = "Name of the ECS Fargate cluster"
  type        = string
  default     = ""
}

variable "fargate_service_names" {
  description = "List of ECS Fargate service names"
  type        = list(string)
  default     = []
}
```
#### **Configurações de Logs e Custos**
``` terraform
variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 3  # Keep retention very low to minimize costs
}

variable "create_basic_alarms" {
  description = "Create basic CloudWatch alarms"
  type        = bool
  default     = false  # Default to false to minimize costs
}

variable "create_dashboard" {
  description = "Create a CloudWatch dashboard"
  type        = bool
  default     = false  # Default to false to minimize costs
}

variable "dashboard_name" {
  description = "Name for the CloudWatch dashboard"
  type        = string
  default     = "pedidos-dashboard"
}
```
## 📤 Outputs do Módulo
### **outputs.tf**
``` terraform
output "api_gateway_log_group_name" {
  description = "The name of the CloudWatch log group for API Gateway"
  value       = var.enable_api_gateway_logs ? aws_cloudwatch_log_group.api_gateway[0].name : null
}

output "lambda_log_group_names" {
  description = "Map of Lambda function names and their CloudWatch log group names"
  value       = var.enable_lambda_logs ? { for name, log_group in aws_cloudwatch_log_group.lambda : name => log_group.name } : null
}

output "fargate_log_group_names" {
  description = "Map of Fargate service names and their CloudWatch log group names"
  value       = var.enable_fargate_logs ? { for name, log_group in aws_cloudwatch_log_group.fargate : name => log_group.name } : null
}

output "api_gateway_alarm_arn" {
  description = "ARN of the API Gateway 5XX errors alarm (if created)"
  value       = var.enable_api_gateway_logs && var.create_basic_alarms ? aws_cloudwatch_metric_alarm.api_gateway_5xx[0].arn : null
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard (if created)"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_arn : null
}
```
## 🔧 Configuração no main.tf Principal
``` terraform
module "cloudwatch" {
  source               = "./modules/cloudwatch"
  region               = var.region
  
  # API Gateway Configuration
  enable_api_gateway_logs = true
  api_gateway_name        = module.api_gateway.api_id
  api_gateway_stage       = "dev"
  
  # Lambda Configuration
  enable_lambda_logs    = true
  lambda_function_names = [
    module.lambda_get_pedido.function_name,
    module.lambda_delete_pedido.function_name
  ]
  
  # Fargate Configuration
  enable_fargate_logs    = true
  fargate_cluster_name   = module.fargate_post_pedido.fargate_cluster_id
  fargate_service_names  = [
    "post-pedido-service",
    "put-pedido-service"
  ]
  
  # Log Retention & Optional Features
  log_retention_days    = 3      # Very low retention to minimize costs
  create_basic_alarms   = false  # Set to true if you want basic alarms
  create_dashboard      = false  # Set to true if you want a dashboard
  
  tags = {
    Environment = "dev"
    Projeto     = "PedidosAPI"
  }
}
```
## 🎛️ Funcionalidades Condicionais
### **Ativação Seletiva por Serviço**

| Serviço | Variável de Controle | Padrão | Função |
| --- | --- | --- | --- |
| **API Gateway** | `enable_api_gateway_logs` | `true` | Ativa logs do API Gateway |
| **Lambda** | `enable_lambda_logs` | `true` | Ativa logs de todas as funções Lambda |
| **Fargate** | `enable_fargate_logs` | `true` | Ativa logs de todos os serviços Fargate |
| **Alarmes** | `create_basic_alarms` | `false` | Cria alarmes básicos |
| **Dashboard** | `create_dashboard` | `false` | Cria dashboard unificado |
### **Otimização de Custos**
``` terraform
# Configuração para ambiente de desenvolvimento (baixo custo)
log_retention_days    = 3      # Apenas 3 dias de retenção
create_basic_alarms   = false  # Sem alarmes para reduzir custos
create_dashboard      = false  # Sem dashboard para reduzir custos

# Configuração para ambiente de produção (monitoramento completo)
log_retention_days    = 30     # 30 dias de retenção
create_basic_alarms   = true   # Alarmes ativos
create_dashboard      = true   # Dashboard para visibilidade
```
## 📊 Métricas Monitoradas
### **API Gateway**
- **Count**: Total de requisições
- **4XXError**: Erros de cliente (400-499)
- **5XXError**: Erros de servidor (500-599)
- **Latency**: Tempo de resposta
- **IntegrationLatency**: Tempo de integração com backend

### **Lambda**
- **Invocations**: Número de invocações
- **Errors**: Erros de execução
- **Duration**: Tempo de execução
- **Throttles**: Execuções limitadas
- **ConcurrentExecutions**: Execuções simultâneas

### **ECS Fargate**
- **CPUUtilization**: Utilização de CPU
- **MemoryUtilization**: Utilização de memória
- **RunningTaskCount**: Número de tasks em execução
- **ServiceEvents**: Eventos do serviço

## 📈 Estrutura de Nomenclatura
### **Grupos de Logs**
``` 
/aws/apigateway/{api-name}           # API Gateway
/aws/lambda/{function-name}          # Lambda Functions
/aws/ecs/{cluster-name}/{service}    # ECS Fargate
```
### **Alarmes**
``` 
{api-name}-5xx-errors               # Alarme de erros 5XX
{service-name}-cpu-high             # Alarme de CPU alta
{function-name}-error-rate          # Alarme de taxa de erro
```
### **Dashboards**
``` 
{dashboard-name}                    # Dashboard principal
```
## 💰 Considerações de Custo
### **Custos por Componente**

| Componente | Custo | Estratégia de Otimização |
| --- | --- | --- |
| **Log Storage** | $0.50/GB/mês | Retenção mínima (3 dias) |
| **Log Ingestion** | $0.50/GB | Logs essenciais apenas |
| **Metrics** | $0.30/métrica/mês | Métricas nativas gratuitas |
| **Alarms** | $0.10/alarme/mês | Alarmes opcionais |
| **Dashboards** | $3.00/dashboard/mês | Dashboard opcional |
### **Estimativa de Custos Mensais (Ambiente Dev)**
``` 
Logs (estimativa: 1GB/mês):
- Ingestão: $0.50
- Armazenamento (3 dias): ~$0.04
- Total: ~$0.54/mês

Sem alarmes e dashboard: $0.00
Total estimado: ~$0.54/mês
```
## 🔗 Integração com Outros Módulos
### **Dependências de Input**
``` mermaid
graph TD
    A[API Gateway Module] --> B[CloudWatch Module]
    C[Lambda Functions Module] --> B
    D[Fargate Module] --> B
    B --> E[Log Groups]
    B --> F[Metrics]
    B --> G[Alarms]
    B --> H[Dashboard]
```
### **Fluxo de Dados**
1. **Módulos de Aplicação** → Geram logs e métricas
2. **CloudWatch Module** → Configura destinos e retenção
3. **Log Groups** → Coletam e armazenam logs
4. **Métricas** → Coletam dados de performance
5. **Alarmes** → Monitoram limites críticos
6. **Dashboard** → Apresenta visão unificada

## 🚀 Boas Práticas Implementadas
### **1. Configuração Condicional**
- Recursos opcionais para controle de custos
- Ativação seletiva por tipo de serviço
- Flexibilidade para diferentes ambientes

### **2. Otimização de Custos**
- Retenção mínima por padrão
- Alarmes e dashboards opcionais
- Configuração adequada para desenvolvimento

### **3. Nomenclatura Padronizada**
- Seguimento de convenções AWS
- Facilita localização e organização
- Suporte a múltiplos ambientes

### **4. Observabilidade Completa**
- Logs de todos os componentes críticos
- Métricas essenciais de performance
- Alarmes para problemas críticos
- Dashboard unificado para visão geral
