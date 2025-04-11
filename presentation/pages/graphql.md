---
layout: full
---

<h1 class="no-mb font-300">Terraform</h1>
<h3 class="font-xs">Uso do <strong>Uso terraform</strong></h3>

<div class="flex gap-4 mt-2">

<div style="width: 50%">
<v-clicks>


```ts{all|2}
provider "aws" {
  region = "us-east-1"
}
```

```ts{all|5-8|14|all}
resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-name"
  acl    = "private"
}

resource "aws_iam_role" "example_role" {
  name = "example-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
```

</v-clicks>
</div>
<div>
<v-clicks>
    <h4 class="font-300"><strong>Terraform:</strong> Vantagens & Desvantagens</h4>

<div class="flex flex-col gap-2 mt-2">
<div class="flex gap-1 font-300 text-sm items-center">
    <akar-icons:circle-check-fill class="text-success" />
    <span>Provisionamento automatizado de infraestrutura em nuvem;</span>
</div>

<div class="flex gap-1 font-300 text-sm items-center">
    <akar-icons:circle-check-fill class="text-success" />
    <span>Controle de versões da infraestrutura com a definição de código;</span>
</div>

<div class="flex gap-1 font-300 text-sm items-center mt-4">
    <ant-design:close-circle-fill class="text-danger" />
    <span>Curva de aprendizagem elevada;</span>
</div>
<div class="flex gap-1 font-300 text-sm items-center">
    <ant-design:close-circle-fill class="text-danger" />
   <span>Gerenciamento de estado;</span>
</div>
<div class="flex gap-1 font-300 text-sm items-center">
    <ant-design:close-circle-fill class="text-danger" />
    <span>Erros de configuração;</span>
</div>
</div>

</v-clicks>
</div>
</div>