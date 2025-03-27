output "lambda_function_name" {
  value = aws_lambda_function.hello_lambda.function_name
}

output "api_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/dev/hello"
}