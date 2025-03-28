output "get_pedido_url" {
  value = "GET → ${module.api_gateway.url}/pedido/{id}"
}

output "delete_pedido_url" {
  value = "DELETE → ${module.api_gateway.url}/pedido/{id}"
}

output "dynamodb_table_name" {
  value = module.dynamodb_pedidos.table_name
}