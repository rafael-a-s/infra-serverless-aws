# 📦 API de Pedidos - Serverless com AWS Lambda e Fargate

## 📌 Tecnologias Utilizadas

### **Backend**
- [Node.js](https://nodejs.org/) - Plataforma para execução do backend
- [Express.js](https://expressjs.com/) - Framework para criar APIs REST
- [AWS Lambda](https://aws.amazon.com/lambda/) - Funções serverless para operações rápidas
- [AWS Fargate](https://aws.amazon.com/fargate/) - Containers gerenciados para operações pesadas
- [AWS API Gateway](https://aws.amazon.com/api-gateway/) - Gerenciamento das requisições HTTP
- [DynamoDB](https://aws.amazon.com/dynamodb/) ou [RDS](https://aws.amazon.com/rds/) - Armazenamento de pedidos
- [Docker](https://www.docker.com/) - Containerização do backend para rodar no Fargate

### **DevOps e Monitoramento**
- [AWS IAM](https://aws.amazon.com/iam/) - Controle de permissões e autenticação
- [AWS CloudWatch](https://aws.amazon.com/cloudwatch/) - Logs e monitoramento do sistema
- [GitHub Actions](https://github.com/features/actions) - Pipeline de CI/CD
- [AWS CodePipeline](https://aws.amazon.com/codepipeline/) - Automação do deploy

---

## 🔄 Fluxo do Sistema

1. **Usuário faz uma requisição à API (via API Gateway)**
2. Dependendo do método HTTP:
   - `GET /pedidos` → API Gateway chama **AWS Lambda**, que busca os pedidos no **DynamoDB**.
   - `DELETE /pedidos/:id` → API Gateway chama **AWS Lambda**, que exclui um pedido.
   - `POST /pedidos` → API Gateway chama **AWS Lambda**, que inicia um container no **AWS Fargate** para processar a criação do pedido.
   - `PUT /pedidos/:id` → API Gateway chama **AWS Lambda**, que também inicia um **Fargate** para atualizar um pedido.
3. O **Fargate** executa a lógica do pedido (validação, processamento) e salva no **banco de dados**.
4. O cliente recebe uma resposta com o status da operação.

---

## 📅 Cronograma de Desenvolvimento

### 📌 **Fase 1: Planejamento e Configuração do Ambiente (22/02 a 08/03)**
- [ ] **22/02 - 23/02** → Definir requisitos e modelar a arquitetura do sistema.
- [ ] **26/02 - 27/02** → Criar conta AWS, configurar permissões IAM e roles para Lambda e Fargate.
- [ ] **28/02 - 01/03** → Estudar AWS Lambda, AWS Fargate e API Gateway, definindo fluxos da API.
- [ ] **04/03 - 08/03** → Configurar ambiente local com Docker e AWS CLI para testes iniciais.

### 📌 **Fase 2: Desenvolvimento da API e Funções Serverless (11/03 a 29/03)**
- [ ] **11/03 - 15/03** → Criar funções AWS Lambda básicas para operações de leitura e exclusão de pedidos.
- [ ] **18/03 - 22/03** → Criar um container Docker para a aplicação backend e testar localmente.
- [ ] **25/03 - 29/03** → Configurar AWS Fargate para rodar o container e integrar com API Gateway.

### 📌 **Fase 3: Banco de Dados, Monitoramento e Escalabilidade (01/04 a 19/04)**
- [ ] **01/04 - 05/04** → Escolher e configurar banco de dados (DynamoDB ou RDS).
- [ ] **08/04 - 12/04** → Implementar comunicação entre Lambda/Fargate e o banco de dados.
- [ ] **15/04 - 19/04** → Configurar logs e monitoramento com AWS CloudWatch.

### 📌 **Fase 4: Segurança, CI/CD e Otimização (22/04 a 10/05)**
- [ ] **22/04 - 26/04** → Implementar autenticação e segurança com IAM e API Gateway.
- [ ] **29/04 - 03/05** → Criar pipeline CI/CD para deploy automático (GitHub Actions, AWS CodePipeline).
- [ ] **06/05 - 10/05** → Otimizar tempo de resposta das funções Lambda e dos containers.

### 📌 **Fase 5: Testes Finais, Documentação e Entrega (13/05 a 31/05)**
- [ ] **13/05 - 17/05** → Testes de carga e validação da escalabilidade do sistema.
- [ ] **20/05 - 24/05** → Escrever documentação técnica e criar guias de uso.
- [ ] **27/05 - 31/05** → Preparar apresentação final e revisar o funcionamento do sistema.

---

## 📖 Como Rodar o Projeto Localmente

1. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/api-pedidos.git
   cd api-pedidos
   ```
2. Instale as dependências:
   ```bash
   npm install
   ```
3. Configure o **AWS CLI**:
   ```bash
   aws configure
   ```
4. Execute a aplicação localmente com Docker:
   ```bash
   docker-compose up
   ```
5. Para rodar Lambda localmente, use **AWS SAM**:
   ```bash
   sam local invoke
   ```

---

## 📌 Próximos Passos
- [ ] Criar infraestrutura no AWS (ECS, Lambda, API Gateway).
- [ ] Implementar a comunicação entre Lambda e Fargate.
- [ ] Testar as chamadas da API e otimizar performance.

Se precisar de ajuda, entre em contato! 🚀🔥
