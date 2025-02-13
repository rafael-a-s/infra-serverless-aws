resource "aws_dynamodb_table" "pedidos_table" {
  name           = "Pedidos"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "pedido_id"
  attribute {
    name = "pedido_id"
    type = "S"
  }
}