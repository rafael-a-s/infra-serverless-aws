###################################################
# CloudWatch Module
# Creates log groups for API Gateway, Lambda and ECS Fargate
# with minimal retention to keep costs low
###################################################

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  count             = var.enable_api_gateway_logs ? 1 : 0
  name              = "/aws/apigateway/${var.api_gateway_name}"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    var.tags,
    {
      Name = "API-Gateway-Logs-${var.api_gateway_name}"
    }
  )
}

# CloudWatch Log Groups for Lambda Functions
resource "aws_cloudwatch_log_group" "lambda" {
  for_each          = var.enable_lambda_logs ? toset(var.lambda_function_names) : []
  name              = "/aws/lambda/${each.value}"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    var.tags,
    {
      Name = "Lambda-Logs-${each.value}"
    }
  )
}

# CloudWatch Log Group for ECS Fargate Services
resource "aws_cloudwatch_log_group" "fargate" {
  for_each          = var.enable_fargate_logs ? toset(var.fargate_service_names) : []
  name              = "/aws/ecs/${element(split("/", var.fargate_cluster_name), length(split("/", var.fargate_cluster_name)) - 1)}/${each.value}"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    var.tags,
    {
      Name = "Fargate-Logs-${each.value}"
    }
  )
}

# Basic CloudWatch Alarm for API Gateway 5XX Errors (if enabled)
resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx" {
  count               = var.enable_api_gateway_logs && var.create_basic_alarms ? 1 : 0
  alarm_name          = "${var.api_gateway_name}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This alarm monitors for API Gateway 5XX errors"
  
  dimensions = {
    ApiName = var.api_gateway_name
    Stage   = var.api_gateway_stage
  }
}

# Basic CloudWatch Dashboard with minimal widgets
resource "aws_cloudwatch_dashboard" "main" {
  count          = var.create_dashboard ? 1 : 0
  dashboard_name = var.dashboard_name
  
  dashboard_body = jsonencode({
    widgets = concat(
      # API Gateway widget (if enabled)
      var.enable_api_gateway_logs ? [{
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_gateway_name, "Stage", var.api_gateway_stage],
            [".", "4XXError", ".", ".", ".", "."],
            [".", "5XXError", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "API Gateway Metrics"
        }
      }] : [],
      
      # Lambda widget (if enabled)
      var.enable_lambda_logs && length(var.lambda_function_names) > 0 ? [{
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            for i, name in var.lambda_function_names : 
              ["AWS/Lambda", "Invocations", "FunctionName", name]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "Lambda Invocations"
        }
      }] : [],
      
      # Fargate widget (if enabled)
      var.enable_fargate_logs && length(var.fargate_service_names) > 0 ? [{
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            for i, name in var.fargate_service_names :
              ["AWS/ECS", "CPUUtilization", "ServiceName", name, "ClusterName", var.fargate_cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Fargate CPU Utilization"
        }
      }] : []
    )
  })
}