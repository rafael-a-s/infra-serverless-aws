## Implementação da Função Lambda

Após implementar o código da sua função Lambda, é necessário **compactar o código em um arquivo ZIP**, pois este formato é requerido pelo módulo Terraform do Lambda para deployment.

### Exemplo de uso no Terraform:
```hcl 
module "lambda_get_pedido" {
  source   = "./modules/lambda_function" function_name = "getPedido"
  filename = "${path.module}/lambda/getPedido/function.zip"role_arn = module.lambda_role.role_arn
  depends_on = [module.lambda_role]
}
``` 

> **Importante:** O parâmetro `filename` deve apontar para o arquivo ZIP contendo todo o código da função Lambda e suas dependências.