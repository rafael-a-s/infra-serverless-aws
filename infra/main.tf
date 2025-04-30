module "lambda_role" {
  source             = "./modules/lambda_role"
  role_name          = "lambda_exec_role"
  dynamodb_table_arn = module.dynamodb_pedidos.table_arn
}

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

# MÓDULOS FARGATE
module "fargate_post_pedido" {
  source              = "./modules/fargate"
  cluster_name        = "fargate-cluster"
  post_pedido_image   = "637423576760.dkr.ecr.us-east-1.amazonaws.com/post-pedido:latest"
  put_pedido_image    = "637423576760.dkr.ecr.us-east-1.amazonaws.com/put-pedido:latest"
  
  subnets             = ["subnet-09d66670545f16a07"]
  security_groups     = ["sg-0673c87a97e88ad2f"]
  vpc_id              = "vpc-03712270d4a22c15f"
}

output "fargate_cluster_id" {
  value = module.fargate_post_pedido.fargate_cluster_id
}

# MÓDULOS LAMBDA

module "lambda_get_pedido" {
  source        = "./modules/lambda_function"
  function_name = "getPedido"
  filename      = "${path.module}/lambda/getPedido/function.zip"
  role_arn      = module.lambda_role.role_arn
  depends_on    = [module.lambda_role]
}

module "lambda_delete_pedido" {
  source        = "./modules/lambda_function"
  function_name = "deletePedido"
  filename      = "${path.module}/lambda/deletePedido/function.zip"
  role_arn      = module.lambda_role.role_arn
  depends_on    = [module.lambda_role]
}

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


module "cloudwatch" {
  source               = "./modules/cloudwatch"
  region               = var.region
  
  # API Gateway Configuration
  enable_api_gateway_logs = true
  api_gateway_name        = module.api_gateway.api_id
  api_gateway_stage       = "dev"
  
  # Lambda Configuration
  enable_lambda_logs    = true
  lambda_function_names = [
    module.lambda_get_pedido.function_name,
    module.lambda_delete_pedido.function_name
  ]
  
  # Fargate Configuration
  enable_fargate_logs    = true
  fargate_cluster_name   = module.fargate_post_pedido.fargate_cluster_id
  fargate_service_names  = [
    "post-pedido-service",
    "put-pedido-service"
  ]
  
  # Log Retention & Optional Features
  log_retention_days    = 3      # Very low retention to minimize costs
  create_basic_alarms   = false  # Set to true if you want basic alarms
  create_dashboard      = false  # Set to true if you want a dashboard
  
  tags = {
    Environment = "dev"
    Projeto     = "PedidosAPI"
  }
}