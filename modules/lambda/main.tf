resource "aws_lambda_function" "get_pedido" {
  function_name = "getPedido"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = "lambda_function.zip"
}