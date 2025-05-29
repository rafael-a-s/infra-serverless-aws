## 📁 Estrutura dos Módulos Lambda
O projeto contém dois módulos principais relacionados ao AWS Lambda:
### 1. **Módulo Lambda Role** (`infra/modules/lambda_role`)
Este módulo é responsável por criar e configurar as permissões necessárias para as funções Lambda.
#### **main.tf**
``` terraform
resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "policy" {
  name = "${var.role_name}-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # CloudWatch Logs
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      # DynamoDB (liga com módulo externo)
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}
```
**Funcionalidade:**
- Cria uma IAM Role que pode ser assumida pelo serviço Lambda
- Define políticas de permissão para:
    - **CloudWatch Logs**: Permite que a Lambda escreva logs
    - **DynamoDB**: Permite operações completas (CRUD) na tabela especificada

#### **variables.tf**
``` terraform
variable "role_name" {
  type        = string
  description = "Nome da role do Lambda"
}

variable "dynamodb_table_arn" {
  type        = string
  description = "ARN da tabela DynamoDB que a Lambda poderá acessar"
}
```
#### **outputs.tf**
``` terraform
output "role_arn" {
  value = aws_iam_role.this.arn
}
```
### 2. **Módulo Lambda Function** (`infra/modules/lambda_function`)
Este módulo cria a função Lambda propriamente dita.
#### **main.tf**
``` terraform
resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  filename         = var.filename
  handler          = var.handler
  runtime          = var.runtime
  role             = var.role_arn
  source_code_hash = filebase64sha256(var.filename)
}
```
**Funcionalidade:**
- Cria a função Lambda com código a partir de um arquivo ZIP
- Utiliza hash do arquivo para detectar mudanças no código
- Conecta a função à IAM Role criada pelo módulo anterior

#### **variables.tf**
``` terraform
variable "function_name" {
  type        = string
  description = "Nome da função Lambda"
}

variable "filename" {
  type        = string
  description = "Caminho para o arquivo .zip da Lambda"
}

variable "handler" {
  type        = string
  default     = "index.handler"
  description = "Handler da Lambda"
}

variable "runtime" {
  type        = string
  default     = "nodejs18.x"
  description = "Runtime da Lambda"
}

variable "role_arn" {
  type        = string
  description = "ARN da role usada pela Lambda"
}
```
#### **outputs.tf**
``` terraform
output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}
```
## 🔗 Integração Entre Módulos
### **Fluxo de Dependências:**
1. **lambda_role** → Cria IAM Role com permissões
2. **lambda_function** → Usa a Role criada para executar a função
3. **DynamoDB** → A Lambda tem permissões para acessar a tabela

### **Configurações Padrão:**
- **Runtime**: Node.js 18.x
- **Handler**: index.handler
- **Permissões**: CloudWatch Logs + DynamoDB completo

### **Saídas Importantes:**
- `role_arn`: ARN da role criada (usado pelo módulo de função)
- `function_name`: Nome da função Lambda
- : ARN para invocar a função (usado pelo API Gateway) `invoke_arn`

## 📋 Uso Recomendado
Para usar esses módulos, você precisará:
1. **Preparar o código:** Criar um arquivo ZIP com sua função Lambda
2. **Configurar variáveis:** Definir nome da função, role e ARN do DynamoDB
3. **Importar módulos:** Usar ambos os módulos em sequência
4. **Conectar outputs:** Passar o `role_arn` do módulo role para o módulo function
****