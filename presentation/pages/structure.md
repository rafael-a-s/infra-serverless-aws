---
layout: two-cols
---

<template v-slot:default>
<h1 class="abs-bl font-extrabold">Estrutura</h1>

<div class="flex flex-col gap-2 justify-between">
  <div class="flex flex-col gap-4">
    <v-clicks>
  <StructurePoint number="1" title="Terraform">
    <b>Automação de Infraestrutura</b> - Usado para provisionar recursos AWS, como ECS, Lambda, NLB e VPC.
</StructurePoint>
<StructurePoint number="2" title="API Gateway">
    <b>Gerenciamento de APIs</b> - Encaminha requisições para os containers no ECS e para funções LAMBDA.
</StructurePoint>
<StructurePoint number="3" title="Lambda">
    <b>Funções Serverless</b> - Funções que executam lógica de negócios como GET e DELETE para pedidos.
</StructurePoint>
<StructurePoint number="4" title="Fargate">
    <b>Containers Gerenciados</b> - Utiliza AWS Fargate para executar containers sem a necessidade de gerenciar servidores, POST e PUT.
</StructurePoint>
<StructurePoint number="5" title="DynamoDB">
    <b>Banco NoSQL</b> - Armazenamento de dados de pedidos, com escalabilidade e baixa latência.
</StructurePoint>
    </v-clicks>
  </div>
  <div class="mt-5">
    <a href="https://github.com/rafael-a-s/infra-serverless-aws/" class="inline-flex gap-2 items-center !hover:text-beapt text-sm">
      <jam-gitlab />
      Repositório
    </a>
  </div>
</div>

</template>
<template v-slot:right>

<div class="flex flex-col gap-4">
    <v-clicks>
   <StructurePoint number="6" title="NLB (Network Load Balancer)">
    <b>Exposição Externa</b> - Balanceador de carga para expor os containers para a internet.
</StructurePoint>
<StructurePoint number="7" title="VPC e Subnets">
    <b>Rede Isolada</b> - Subnets públicas configuradas para permitir o tráfego até os containers no Fargate.
</StructurePoint>
<StructurePoint number="8" title="Security Groups">
    <b>Controle de Acesso</b> - Regras para permitir o tráfego nas portas 3000 e 3001 para o NLB.
</StructurePoint>
<StructurePoint number="9" title="IAM Roles">
    <b>Controle de Permissões</b> - Funções para garantir que os serviços da AWS (ECS, Lambda e etc...) tenham as permissões necessárias.
</StructurePoint>
<StructurePoint number="10" title="Postman">
    <b>Testes de API</b> - Ferramenta usada para testar os métodos POST, PUT, GET e DELETE, garantindo a integração com o API Gateway.
</StructurePoint>
    </v-clicks>
</div>
</template>