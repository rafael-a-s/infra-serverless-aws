resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/pedidos-api"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/aws/ecs/pedidos-cluster"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "/aws/rds/pedidos-db"
  retention_in_days = 30
}