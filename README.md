# Sistema de Gerenciamento de Pedidos

## Visão Geral

Este projeto implementa uma API de gerenciamento de pedidos usando uma arquitetura de microserviços na AWS. A infraestrutura é definida como código utilizando Terraform/OpenTofu, seguindo as melhores práticas de IaC (Infrastructure as Code).

## Arquitetura

O sistema é composto por uma API REST completa com operações CRUD (Create, Read, Update, Delete) para a entidade "Pedido", utilizando diferentes serviços da AWS para cada tipo de operação:

![Arquitetura do Sistema](assets/arquitetura.gif)

### Principais Componentes

- **API Gateway**: Ponto de entrada para todas as requisições HTTP
- **AWS Lambda**: Funções serverless para operações GET e DELETE
- **ECS Fargate**: Containers para operações POST e PUT
- **DynamoDB**: Banco de dados NoSQL para armazenamento dos pedidos
- **Network Load Balancer**: Para balanceamento de carga dos containers Fargate
- **CloudWatch**: Monitoramento e logs de todos os componentes

## Endpoints da API

A API expõe os seguintes endpoints:

| Método | Endpoint | Descrição | Implementação |
|--------|----------|-----------|--------------|
| GET | `/pedido/{id}` | Recupera um pedido específico | Lambda |
| DELETE | `/pedido/{id}` | Remove um pedido | Lambda |
| POST | `/pedido` | Cria um novo pedido | Fargate Container |
| PUT | `/pedido/{id}` | Atualiza um pedido existente | Fargate Container |

## Estrutura do Projeto

```plaintext
/
├── modules/
│   ├── api_gateway/        # Configuração do API Gateway
│   ├── cloudwatch/         # Configuração de logs e monitoramento
│   ├── dynamodb/           # Tabela DynamoDB para armazenamento
│   ├── fargate/            # Configuração dos serviços ECS Fargate
│   ├── lambda_function/    # Funções Lambda para GET e DELETE
│   └── lambda_role/        # IAM Roles para as funções Lambda
├── lambda/
│   ├── getPedido/          # Código-fonte da função GET
│   └── deletePedido/       # Código-fonte da função DELETE
├── main.tf                 # Configuração principal do Terraform
├── variables.tf            # Definição de variáveis
├── outputs.tf              # Outputs do Terraform
└── terraform.tfvars        # Valores das variáveis para o ambiente
```


## Pré-requisitos

- Terraform ou OpenTofu >= 0.12
- AWS CLI configurado com credenciais apropriadas
- Docker (para build local das imagens, se necessário)

## Configuração e Implantação

### 1. Configuração de Variáveis

Edite o arquivo `terraform.tfvars` para configurar os valores específicos do seu ambiente:

### 2. Inicialização e Planejamento
```bash
# Inicializar o Terraform
terraform init

# Verificar o plano de execução
terraform plan
```

### 3. Implantação

```bash
# Aplicar as mudanças
terraform apply
```

### 4. Verificação

Após a implantação, os endpoints da API serão exibidos como outputs do Terraform:

```hcl
get_pedido_url    = "GET → https://xxxxxx.execute-api.us-east-1.amazonaws.com/dev/pedido/{id}"
delete_pedido_url = "DELETE → https://xxxxxx.execute-api.us-east-1.amazonaws.com/dev/pedido/{id}"
```


## Detalhes da Implementação

### Lambda Functions

- Funções serverless para operações leves (GET e DELETE)
- Implementadas em Node.js
- Acesso direto ao DynamoDB através de IAM Roles

### Fargate Containers

- Serviços containerizados para operações mais complexas (POST e PUT)
- Executados em ECS Fargate (serverless containers)
- Expostos através de Network Load Balancer
- Configurados com health checks e auto-scaling

### Banco de Dados

- DynamoDB como banco de dados NoSQL
- Tabela "Pedidos" com chave primária "id"
- Acesso controlado por IAM policies específicas

### Monitoramento

- CloudWatch Logs configurado para todos os componentes
- Retenção de logs configurada para 3 dias (otimização de custos)
- Possibilidade de ativar alarmes e dashboards (desativado por padrão)

## Segurança

- IAM Roles com privilégios mínimos para cada componente
- VPC Link para conexão segura entre API Gateway e containers Fargate
- Security Groups para controle de acesso à rede

## Considerações sobre Custos

Este projeto utiliza diversos serviços da AWS com diferentes modelos de cobrança:

- **Lambda**: Cobrança por execução e tempo de execução
- **Fargate**: Cobrança por vCPU e memória alocada
- **API Gateway**: Cobrança por requisição
- **DynamoDB**: Cobrança por capacidade provisionada ou sob demanda
- **CloudWatch**: Cobrança por ingestão e armazenamento de logs

Para otimização de custos:
- A retenção de logs está configurada para apenas 3 dias
- Os containers Fargate usam configurações mínimas (256 CPU units, 512MB RAM)
- Dashboards e alarmes estão desativados por padrão

## Contribuição

Para contribuir com este projeto:

1. Faça um fork do repositório
2. Crie um branch para sua feature (`git checkout -b feature/nova-feature`)
3. Faça commit das suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Faça push para o branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## Licença

[Incluir informação de licença]