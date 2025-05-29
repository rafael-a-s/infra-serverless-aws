## 📁 Estrutura do Módulo DynamoDB
O módulo DynamoDB (`infra/modules/dynamodb`) é responsável por criar e configurar a tabela do banco de dados NoSQL que armazena os dados dos pedidos no sistema.
## 🗄️ Componente Principal
### **Tabela DynamoDB**
#### **main.tf**
``` terraform
resource "aws_dynamodb_table" "this" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = var.hash_key_name

  attribute {
    name = var.hash_key_name
    type = var.hash_key_type
  }

  tags = var.tags
}
```
**Funcionalidades:**
- **Nome da Tabela**: Definido através da variável `table_name`
- **Modo de Cobrança**: `PAY_PER_REQUEST` (sob demanda) para otimização de custos
- **Chave Primária**: Configurável através das variáveis `hash_key_name` e `hash_key_type`
- **Atributos**: Define apenas a chave primária (outros atributos são criados dinamicamente)
- **Tags**: Permite categorização e organização da tabela

## 📝 Variáveis do Módulo
### **variables.tf**
``` terraform
variable "table_name" {
  type        = string
  description = "Nome da tabela do DynamoDB"
}

variable "hash_key_name" {
  type        = string
  description = "Nome da chave primária"
}

variable "hash_key_type" {
  type        = string
  description = "Tipo da chave primária (S, N, B)"
  default     = "S"
}

variable "tags" {
  type        = map(string)
  description = "Tags da tabela"
  default     = {}
}
```
**Detalhes das Variáveis:**

| Variável | Tipo | Descrição | Padrão | Obrigatória |
| --- | --- | --- | --- | --- |
| `table_name` | string | Nome da tabela DynamoDB | - | ✅ |
| `hash_key_name` | string | Nome da chave primária | - | ✅ |
| `hash_key_type` | string | Tipo da chave (S=String, N=Number, B=Binary) | "S" | ❌ |
| `tags` | map(string) | Tags para organização e billing | {} | ❌ |
## 📤 Outputs do Módulo
### **outputs.tf**
``` terraform
output "table_name" {
  value = aws_dynamodb_table.this.name
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}
```
**Saídas Disponíveis:**
- **`table_name`**: Nome da tabela criada (usado para referenciar a tabela em aplicações)
- **`table_arn`**: ARN da tabela (usado para configurar permissões IAM)

## 🔧 Configuração no main.tf Principal
``` terraform
module "dynamodb_pedidos" {
  source         = "./modules/dynamodb"
  table_name     = "Pedidos"
  hash_key_name  = "id"
  hash_key_type  = "S"
  tags = {
    Environment = "dev"
    Projeto     = "LambdaPedidos"
  }
}
```
**Configuração Específica do Projeto:**
- **Nome da Tabela**: "Pedidos"
- **Chave Primária**: "id" (tipo String)
- **Ambiente**: Desenvolvimento
- **Projeto**: Sistema de Lambda para Pedidos

## 🏗️ Características Técnicas
### **Modo de Cobrança: PAY_PER_REQUEST**
**Vantagens:**
- ✅ **Sem custos fixos**: Paga apenas pelo que usar
- ✅ **Auto-scaling**: Capacidade ajustada automaticamente
- ✅ **Simplicidade**: Não requer configuração de capacidade
- ✅ **Ideal para workloads variáveis**: Perfeito para APIs com tráfego irregular

**Características:**
- Cobrança por requisição (leitura/escrita)
- Sem necessidade de provisionar capacidade
- Escalabilidade automática e instantânea
- Ideal para ambientes de desenvolvimento e cargas de trabalho imprevisíveis

### **Esquema de Dados**
``` json
{
  "id": "string (chave primária)",
  "campo1": "valor dinâmico",
  "campo2": "valor dinâmico",
  "...": "outros campos conforme necessário"
}
```
**Flexibilidade:**
- **Schema-less**: Campos podem ser adicionados dinamicamente
- **Tipos Suportados**: String, Number, Binary, Boolean, List, Map, Set
- **Consultas**: Por chave primária (mais eficiente) ou scan (menos eficiente)

### **Operações Suportadas**

| Operação | Descrição | Usado Por |
| --- | --- | --- |
| **PutItem** | Criar/Substituir item | Fargate (POST) |
| **UpdateItem** | Atualizar item existente | Fargate (PUT) |
| **GetItem** | Recuperar item por chave | Lambda (GET) |
| **DeleteItem** | Remover item | Lambda (DELETE) |
| **Scan** | Varrer toda a tabela | Consultas complexas |
| **Query** | Consultar por chave | Consultas eficientes |
## 🔐 Integração com Permissões IAM
### **Permissões para Lambda (GET/DELETE)**
``` terraform
# No módulo lambda_role
"dynamodb:GetItem",
"dynamodb:DeleteItem",
"dynamodb:Scan",
"dynamodb:Query"
```
### **Permissões para Fargate (POST/PUT)**
``` terraform
# No módulo fargate
"dynamodb:PutItem",
"dynamodb:UpdateItem"
```
**Princípio de Menor Privilégio:**
- Cada serviço tem apenas as permissões necessárias
- Lambda: Leitura e exclusão
- Fargate: Criação e atualização

## 🔗 Integração com Outros Módulos
### **Dependências:**
``` mermaid
graph TD
    A[DynamoDB Module] --> B[Lambda Role Module]
    A --> C[Fargate Module]
    B --> D[Lambda Functions]
    C --> E[ECS Services]
```
**Fluxo de Dependências:**
1. **DynamoDB** → Cria tabela e expõe ARN
2. **Lambda Role** → Usa ARN para criar permissões
3. **Fargate** → Usa ARN para criar permissões
4. **Lambda Functions** → Acessa tabela via Role
5. **ECS Services** → Acessa tabela via Role

### **Outputs Utilizados:**
- **`table_arn`**: Usado pelos módulos e para configurar permissões IAM `lambda_role``fargate`
- **`table_name`**: Usado pelas aplicações para referenciar a tabela

## 📊 Monitoramento e Métricas
### **Métricas Automáticas do DynamoDB:**
- **ConsumedReadCapacityUnits**: Unidades de leitura consumidas
- **ConsumedWriteCapacityUnits**: Unidades de escrita consumidas
- **ThrottledRequests**: Requisições limitadas
- **UserErrors**: Erros de cliente (4xx)
- **SystemErrors**: Erros de sistema (5xx)

### **CloudWatch Integration:**
- Logs automáticos de operações
- Métricas de performance em tempo real
- Possibilidade de criar alarmes personalizados

## 💰 Considerações de Custo
### **Modelo PAY_PER_REQUEST:**
**Custos por Região (US East 1):**
- **Leitura**: $0.25 por milhão de unidades de leitura
- **Escrita**: $1.25 por milhão de unidades de escrita
- **Armazenamento**: $0.25 por GB por mês

**Exemplo de Custos Mensais:**
``` 
Para 100.000 operações/mês (50% leitura, 50% escrita):
- 50.000 leituras = $0.0125
- 50.000 escritas = $0.0625
- Total = ~$0.075/mês (muito baixo para desenvolvimento)
```
### **Vantagens para Desenvolvimento:**
- ✅ Custos mínimos para ambientes de teste
- ✅ Sem custos quando não há uso
- ✅ Fácil de prever custos baseado no uso

## 🚀 Boas Práticas Implementadas
### **1. Flexibilidade de Configuração**
- Variáveis parametrizadas para reutilização
- Tipos de chave configuráveis
- Tags customizáveis

### **2. Segurança**
- ARN exposto para configuração de permissões
- Integração com IAM roles específicas
- Princípio de menor privilégio

### **3. Otimização de Custos**
- Modo PAY_PER_REQUEST para workloads variáveis
- Sem over-provisioning de capacidade
- Ideal para ambientes de desenvolvimento

### **4. Manutenibilidade**
- Código modular e reutilizável
- Outputs bem definidos
- Documentação clara das variáveis

## 📝 Exemplo de Uso Completo
``` terraform
# Criação da tabela
module "dynamodb_pedidos" {
  source         = "./modules/dynamodb"
  table_name     = "Pedidos"
  hash_key_name  = "id"
  hash_key_type  = "S"
  tags = {
    Environment = "production"
    Team        = "Backend"
    Project     = "PedidosAPI"
  }
}

# Uso do ARN em outros módulos
module "lambda_role" {
  source             = "./modules/lambda_role"
  role_name          = "lambda_exec_role"
  dynamodb_table_arn = module.dynamodb_pedidos.table_arn
}

# Output para referência externa
output "dynamodb_table_name" {
  value       = module.dynamodb_pedidos.table_name
  description = "Nome da tabela DynamoDB criada"
}
```
