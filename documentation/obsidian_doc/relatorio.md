## Dia 25/02

Crie o usuário no IAM da aws com as permissões awsLambda com acesso completo.

## Dia 27/02

Vi videos e lhi artigos que estão na seções de materiais usados.

## Dia 28/02

Propus uma arquitetura que será avaliada pelo supervisor.

## Dia 10/03

Módulos organizados, e atualizado o repositório no github link do commit. Também foi implementado um código para pré-teste.

## Dia 27/03

## 📌 Etapa de Modularização e Integração com Serviços AWS via Terraform

### 🧠 Situação Inicial

O projeto encontrava-se funcional, mas com os recursos definidos diretamente no `main.tf`, o que dificultava a escalabilidade, reutilização e manutenção da infraestrutura. A função Lambda já estava conectada ao DynamoDB e ao API Gateway, mas ainda sem modularização, e algumas permissões haviam sido adicionadas manualmente.

---

### 🛠️ Objetivo

Modularizar toda a infraestrutura em Terraform, de forma que cada serviço fosse separado em seus respectivos diretórios reutilizáveis (`modules/`), garantindo padronização e reaproveitamento em projetos futuros.

---

### 🚧 Processo de Desenvolvimento

Durante esta etapa, organizamos o projeto em módulos Terraform para:

- Funções Lambda (`lambda_function`)
- Role e política IAM personalizada para Lambda (`lambda_role`)
- Tabela DynamoDB (`dynamodb`)
- API Gateway completo (`api_gateway`)

Cada módulo foi isolado com `main.tf`, `variables.tf` e `outputs.tf`, permitindo uma composição limpa no `main.tf` da raiz do projeto.

Realizamos também:

- Ajuste de variáveis reservadas (`depends_on`)
- Correções de dependências implícitas entre recursos
- Criação de pacotes `.zip` válidos para as funções Lambda
- Ajustes em políticas e permissões IAM
- Atualização dos outputs com a URL da API em ambiente `dev`

---

### ⚠️ Desafios Enfrentados

- Utilização incorreta da variável `depends_on` dentro de módulo (palavra reservada)
- Conflito ao tentar destruir uma policy ainda vinculada a uma role
- Timeout na criação de funções Lambda por causa da ordem de dependência
- Referência quebrada a recursos antigos após modularização

Todos foram resolvidos com:

- Refatoração do módulo para evitar variáveis reservadas
- Uso correto de `depends_on` no `main.tf` externo
- Separação de permissões em um módulo dedicado
- Correção dos outputs e variáveis com base nas novas estruturas

---

### ✅ Resultado Final

Após as mudanças, foi possível aplicar toda a infraestrutura com sucesso via `terraform apply`. A requisição GET foi validada com sucesso em uma função Lambda integrada ao DynamoDB, retornando os dados esperados. O projeto agora está:

- Completamente modularizado
- Fácil de escalar e reutilizar
- Com versionamento limpo e pronto para CI/CD

---

### 📸 Print de resultado final

```json
{
  "id": "1",
  "nome": "Rafael Aguiar"
}

## Dia 02/03

Processo de hoje foi testar o modulo do fargate.
Adicionar as imagens docker no ECS da aws.
Processo:

```JSON

cd fargate
cd postPedido
docker build -t post-pedido .
cd ..
ls
cd putPedido
docker build -t put-pedido .
aws ecr create-repository --repository-name post-pedido
exit
aws ecr create-repository --repository-name post-pedido
aws ecr create-repository --repository-name put-pedido
aws sts get-caller-identity

aws ecr describe-repositories --region us-east-1\

aws sts get-caller-identity\

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <IDAWS>.dkr.ecr.us-east-1.amazonaws.com/post-pedido\

docker tag post-pedido:latest <IDAWS>.dkr.ecr.us-east-1.amazonaws.com/post-pedido:latest
docker push <IDAWS>.dkr.ecr.us-east-1.amazonaws.com/post-pedido:latest
docker tag put-pedido:latest <IDAWS>.dkr.ecr.us-east-1.amazonaws.com/put-pedido:latest
docker push 200~<IDAWS>.dkr.ecr.us-east-1.amazonaws.com/put-pedido:latest
docker push <IDAWS>.dkr.ecr.us-east-1.amazonaws.com/put-pedido:latest