## 📅 Cronograma de Desenvolvimento

### 📌 **Fase 1: Planejamento e Configuração do Ambiente (22/02 a 08/03)**
- [ ] **22/02 - 23/02** → Definir requisitos e modelar a arquitetura do sistema.
- [ ] **26/02 - 27/02** → Criar conta AWS, configurar permissões IAM e roles para Lambda e Fargate.
- [ ] **28/02 - 01/03** → Estudar AWS Lambda, AWS Fargate e API Gateway, definindo fluxos da API.
- [ ] **04/03 - 08/03** → Configurar ambiente local com Terraform e AWS CLI para testes iniciais.

### 📌 **Fase 2: Provisionamento da Infraestrutura com Terraform (11/03 a 29/03)**
- [ ] **11/03 - 15/03** → Criar os módulos Terraform para IAM, VPC e API Gateway.
- [ ] **18/03 - 22/03** → Criar os módulos Terraform para AWS Lambda e AWS Fargate.
- [ ] **25/03 - 29/03** → Implementar a integração entre os serviços provisionados.

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