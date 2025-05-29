## 📁 Estrutura do Módulo API Gateway
O módulo API Gateway (`infra/modules/api_gateway`) é responsável por criar e configurar a API REST que serve como ponto de entrada único para todas as operações CRUD do sistema de gerenciamento de pedidos.
## 🎯 Objetivo Principal
Este módulo centraliza todas as requisições HTTP e roteia para os backends apropriados:
- **GET/DELETE**: Roteadas para funções Lambda
- **POST/PUT**: Roteadas para containers Fargate via VPC Link

## 🏗️ Componentes Principais
### **1. API REST Principal**
#### **REST API**
``` terraform
resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description
}
```
**Funcionalidade:**
- Cria a API REST principal
- Ponto de entrada para todas as requisições
- Gerencia autenticação e autorização

### **2. Estrutura de Recursos**
#### **Recursos da API**
``` terraform
# Recurso /pedido
resource "aws_api_gateway_resource" "pedido" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "pedido"
}

# Recurso /pedido/{id}
resource "aws_api_gateway_resource" "pedido_id" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.pedido.id
  path_part   = "{id}"
}
```
**Estrutura de URLs:**
``` 
/                     # Root resource
└── /pedido           # Base para operações de pedido
    └── /pedido/{id}  # Para operações com ID específico
```
### **3. Métodos HTTP e Integrações**
#### **GET /pedido/{id} → Lambda**
``` terraform
# Método GET
resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.pedido_id.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.id" = true
  }
}

# Integração com Lambda
resource "aws_api_gateway_integration" "get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.pedido_id.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_get_invoke_arn
}

# Permissão Lambda
resource "aws_lambda_permission" "get" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_get_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}
```
#### **DELETE /pedido/{id} → Lambda**
``` terraform
# Método DELETE
resource "aws_api_gateway_method" "delete" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.pedido_id.id
  http_method   = "DELETE"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.id" = true
  }
}

# Integração com Lambda
resource "aws_api_gateway_integration" "delete" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.pedido_id.id
  http_method             = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_delete_invoke_arn
}

# Permissão Lambda
resource "aws_lambda_permission" "delete" {
  statement_id  = "AllowAPIGatewayInvokeDelete"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_delete_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}
```
### **4. VPC Link para Fargate**
#### **VPC Link**
``` terraform
resource "aws_api_gateway_vpc_link" "fargate_vpc_link" {
  name        = "fargate-vpc-link"
  target_arns = [var.nlb_arn]
}
```
**Funcionalidade:**
- Conecta API Gateway à infraestrutura privada
- Permite acesso aos containers Fargate através do NLB
- Conexão segura sem exposição direta à internet

#### **POST /pedido → Fargate**
``` terraform
# Método POST
resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.pedido.id
  http_method   = "POST"
  authorization = "NONE"
  request_models = {
    "application/json" = "Empty"
  }
}

# Integração com Fargate
resource "aws_api_gateway_integration" "post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.pedido.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "HTTP"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.fargate_vpc_link.id
  uri                     = "http://${var.nlb_dns_name}:3000/pedido"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/json'"
  }
}

# Resposta 201 Created
resource "aws_api_gateway_method_response" "post_201" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.pedido.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "201"

  response_models = {
    "application/json" = "Empty"
  }
}

# Integração de resposta
resource "aws_api_gateway_integration_response" "post_201" {
  depends_on = [aws_api_gateway_integration.post]
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.pedido.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.post_201.status_code

  response_templates = {
    "application/json" = ""
  }
}
```
#### **PUT /pedido/{id} → Fargate**
``` terraform
# Método PUT
resource "aws_api_gateway_method" "put" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.pedido_id.id
  http_method   = "PUT"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.id" = true
  }
}

# Integração com Fargate
resource "aws_api_gateway_integration" "put" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.pedido_id.id
  http_method             = aws_api_gateway_method.put.http_method
  integration_http_method = "PUT"
  type                    = "HTTP"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.fargate_vpc_link.id
  uri                     = "http://${var.nlb_dns_name}:3001/pedido/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Content-Type" = "'application/json'"
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}

# Resposta 200 OK
resource "aws_api_gateway_method_response" "put_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.pedido_id.id
  http_method = aws_api_gateway_method.put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# Integração de resposta
resource "aws_api_gateway_integration_response" "put_200" {
  depends_on = [aws_api_gateway_integration.put]
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.pedido_id.id
  http_method = aws_api_gateway_method.put.http_method
  status_code = aws_api_gateway_method_response.put_200.status_code

  response_templates = {
    "application/json" = ""
  }
}
```
### **5. Deployment**
#### **Deployment da API**
``` terraform
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.get,
    aws_api_gateway_integration.delete,
    aws_api_gateway_integration.post,
    aws_api_gateway_integration.put,
    aws_api_gateway_integration_response.put_200
  ]
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = "dev"
}
```
**Funcionalidade:**
- Publica a API em um stage específico
- Dependências garantem que todas as integrações estejam prontas
- Stage "dev" para ambiente de desenvolvimento

## 📝 Variáveis do Módulo
### **variables.tf**
``` terraform
variable "api_name" {
  type        = string
  description = "Nome da API"
}

variable "api_description" {
  type        = string
  default     = ""
}

variable "lambda_get_invoke_arn" {
  type        = string
  description = "Invoke ARN da função Lambda GET"
}

variable "lambda_get_function_name" {
  type        = string
  description = "Nome da função Lambda GET"
}

variable "lambda_delete_invoke_arn" {
  type        = string
  description = "Invoke ARN da função Lambda DELETE"
}

variable "lambda_delete_function_name" {
  type        = string
  description = "Nome da função Lambda DELETE"
}

variable "region" {
  type        = string
  description = "Região AWS para compor a URL do endpoint"
}

variable "nlb_arn" {
  description = "ARN do NLB para o VPC Link"
  type        = string
}

variable "nlb_dns_name" {
  description = "DNS do NLB"
  type        = string
}
```
## 📤 Outputs do Módulo
### **outputs.tf**
``` terraform
output "api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}

output "url" {
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/dev"
}
```
## 🔧 Configuração no main.tf Principal
``` terraform
module "api_gateway" {
  source                      = "./modules/api_gateway"
  api_name                    = "rafael-api"
  api_description             = "API com operações CRUD para pedidos"
  lambda_get_invoke_arn       = module.lambda_get_pedido.invoke_arn
  lambda_get_function_name    = module.lambda_get_pedido.function_name
  lambda_delete_invoke_arn    = module.lambda_delete_pedido.invoke_arn
  lambda_delete_function_name = module.lambda_delete_pedido.function_name
  region                      = var.region
  nlb_arn                     = module.fargate_post_pedido.fargate_nlb_arn
  nlb_dns_name                = module.fargate_post_pedido.fargate_nlb_dns_name
}
```
## 🛣️ Mapeamento de Rotas
### **Tabela de Endpoints**

| Método | Endpoint | Backend | Porta | Tipo de Integração |
| --- | --- | --- | --- | --- |
| **GET** | `/pedido/{id}` | Lambda (getPedido) | N/A | AWS_PROXY |
| **DELETE** | `/pedido/{id}` | Lambda (deletePedido) | N/A | AWS_PROXY |
| **POST** | `/pedido` | Fargate (post-pedido-service) | 3000 | HTTP via VPC_LINK |
| **PUT** | `/pedido/{id}` | Fargate (put-pedido-service) | 3001 | HTTP via VPC_LINK |
### **Fluxo de Requisições**
``` mermaid
graph TD
    A[Cliente HTTP] --> B[API Gateway]
    B --> C{Método?}
    C -->|GET/DELETE| D[Lambda Function]
    C -->|POST/PUT| E[VPC Link]
    E --> F[Network Load Balancer]
    F --> G[Fargate Container]
    D --> H[DynamoDB]
    G --> H
```
## 🔐 Segurança e Permissões
### **Autorização**
- **Atual**: `authorization = "NONE"` (sem autenticação)
- **Produção**: Recomendado usar IAM, Cognito ou API Keys

### **Permissões Lambda**
``` terraform
resource "aws_lambda_permission" "get" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_get_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}
```
**Funcionalidade:**
- Permite que API Gateway invoque as funções Lambda
- Restrito ao ARN específico da API
- Princípio de menor privilégio

### **VPC Link Security**
- **Isolamento**: Containers Fargate ficam em rede privada
- **Acesso**: Apenas via VPC Link através do NLB
- **Segurança**: Sem exposição direta à internet

## 📊 Tipos de Integração
### **AWS_PROXY (Lambda)**
``` terraform
type                    = "AWS_PROXY"
integration_http_method = "POST"
uri                     = var.lambda_get_invoke_arn
```
**Características:**
- Proxy completo para Lambda
- Headers e body passados automaticamente
- Resposta estruturada automática
- Ideal para funções serverless

### **HTTP (Fargate)**
``` terraform
type                    = "HTTP"
connection_type         = "VPC_LINK"
connection_id           = aws_api_gateway_vpc_link.fargate_vpc_link.id
uri                     = "http://${var.nlb_dns_name}:3000/pedido"
```
**Características:**
- Integração HTTP padrão
- Conexão via VPC Link
- Controle manual de headers e parâmetros
- Ideal para serviços HTTP/REST

## 🎛️ Configuração de Respostas
### **Method Responses**
``` terraform
# POST → 201 Created
resource "aws_api_gateway_method_response" "post_201" {
  status_code = "201"
  response_models = {
    "application/json" = "Empty"
  }
}

# PUT → 200 OK
resource "aws_api_gateway_method_response" "put_200" {
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}
```
### **Integration Responses**
``` terraform
resource "aws_api_gateway_integration_response" "post_201" {
  status_code = "201"
  response_templates = {
    "application/json" = ""  # Passa resposta sem modificação
  }
}
```
## 🔗 Integração com Outros Módulos
### **Dependências de Input**
``` mermaid
graph TD
    A[Lambda Functions] --> B[API Gateway Module]
    C[Fargate NLB] --> B
    B --> D[CloudWatch Logs]
    B --> E[Client Applications]
```
### **Fluxo de Dependências**
1. **Lambda Functions** → Fornecem ARNs de invoke
2. **Fargate Module** → Fornece ARN e DNS do NLB
3. **API Gateway** → Configura roteamento e integrações
4. **CloudWatch** → Usa API ID para logs
5. **Outputs** → Fornecem URLs para clientes

## 💰 Considerações de Custo
### **Modelo de Cobrança**
- **Requisições**: $3.50 por milhão de requisições
- **Transferência de dados**: $0.09 por GB de saída
- **Cache**: Opcional (adicional)

### **Estimativa Mensal (1000 req/dia)**
``` 
30.000 requisições/mês × $3.50/milhão = ~$0.105
Transferência (estimada 1KB/resposta): ~$0.003
Total estimado: ~$0.11/mês
```
## 🚀 Funcionalidades Avançadas
### **1. Passthrough Behavior**
``` terraform
passthrough_behavior = "WHEN_NO_MATCH"
```
- Permite que requisições passem mesmo sem modelo definido
- Flexibilidade para diferentes tipos de payload

### **2. Request Parameters**
``` terraform
request_parameters = {
  "method.request.path.id" = true  # Parâmetro obrigatório
  "integration.request.path.id" = "method.request.path.id"  # Mapeamento
}
```
### **3. Header Injection**
``` terraform
request_parameters = {
  "integration.request.header.Content-Type" = "'application/json'"
}
```
## 📋 Outputs de URL Finais
``` hcl
# No main.tf principal
output "get_pedido_url" {
  value = "GET → ${module.api_gateway.url}/pedido/{id}"
}

output "delete_pedido_url" {
  value = "DELETE → ${module.api_gateway.url}/pedido/{id}"
}
```
**URLs Resultantes:**
``` 
GET → https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/dev/pedido/{id}
DELETE → https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/dev/pedido/{id}
POST → https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/dev/pedido
PUT → https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/dev/pedido/{id}
```
## 🎯 Boas Práticas Implementadas
### **1. Separação de Responsabilidades**
- Lambda para operações leves (GET/DELETE)
- Fargate para operações complexas (POST/PUT)

### **2. Roteamento Inteligente**
- VPC Link para acesso seguro ao Fargate
- Proxy direto para Lambda

### **3. Gestão de Dependências**
- Deployment aguarda todas as integrações
- Permissões explícitas para Lambda

### **4. Flexibilidade de Configuração**
- Variáveis para todos os componentes externos
- Outputs para integração com outros módulos
