resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description
}

resource "aws_api_gateway_resource" "pedido" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "pedido"
}

resource "aws_api_gateway_resource" "pedido_id" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.pedido.id
  path_part   = "{id}"
}

# Método GET
resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.pedido_id.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.id" = true
  }
}

# Integração GET
resource "aws_api_gateway_integration" "get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.pedido_id.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_get_invoke_arn
}

# Permissão GET
resource "aws_lambda_permission" "get" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_get_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# Método DELETE
resource "aws_api_gateway_method" "delete" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.pedido_id.id
  http_method   = "DELETE"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.id" = true
  }
}

# Integração DELETE
resource "aws_api_gateway_integration" "delete" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.pedido_id.id
  http_method             = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_delete_invoke_arn
}

# Permissão DELETE
resource "aws_lambda_permission" "delete" {
  statement_id  = "AllowAPIGatewayInvokeDelete"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_delete_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# Criando o VPC Link
resource "aws_api_gateway_vpc_link" "fargate_vpc_link" {
  name        = "fargate-vpc-link"
  target_arns = [var.nlb_arn]  # Referência ao ARN do NLB
}

# Método POST para o pedido
resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.pedido.id
  http_method   = "POST"
  authorization = "NONE"
  request_models = {
    "application/json" = "Empty"  # Ou use um modelo personalizado se tiver
  }
}

resource "aws_api_gateway_integration" "post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.pedido.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "HTTP"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.fargate_vpc_link.id
  uri                     = "http://${var.nlb_dns_name}:3000/pedido"
  passthrough_behavior    = "WHEN_NO_MATCH"  # Add this line
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/json'"
  }
}

resource "aws_api_gateway_method_response" "post_201" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.pedido.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "201"

  response_models = {
    "application/json" = "Empty"
  }
}

# Configurando a resposta da integração para 201 Created
resource "aws_api_gateway_integration_response" "post_201" {
  depends_on = [aws_api_gateway_integration.post]
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.pedido.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.post_201.status_code

  # Mapeia a resposta do backend para o cliente
  response_templates = {
    "application/json" = ""  # Passa o corpo da resposta sem modificações
  }
}


resource "aws_api_gateway_method" "put" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.pedido_id.id
  http_method   = "PUT"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "put" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.pedido_id.id
  http_method             = aws_api_gateway_method.put.http_method
  integration_http_method = "PUT"
  type                    = "HTTP"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.fargate_vpc_link.id
  uri                     = "http://${var.nlb_dns_name}:3001/pedido/{id}"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
    "integration.request.header.Content-Type" = "'application/json'"
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method_response" "put_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.pedido_id.id
  http_method = aws_api_gateway_method.put.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "put_200" {
  depends_on = [aws_api_gateway_integration.put]
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.pedido_id.id
  http_method = aws_api_gateway_method.put.http_method
  status_code = aws_api_gateway_method_response.put_200.status_code

  response_templates = {
    "application/json" = ""
  }
}


#    Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.get,
    aws_api_gateway_integration.delete,
    aws_api_gateway_integration.post,
    aws_api_gateway_integration.put,
    aws_api_gateway_integration_response.put_200
  ]
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = "dev"
}