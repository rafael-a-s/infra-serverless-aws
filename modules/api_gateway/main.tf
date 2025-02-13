resource "aws_api_gateway_rest_api" "pedidos_api" {
  name        = "pedidos-api"
  description = "API Gateway para gerenciar pedidos"
}