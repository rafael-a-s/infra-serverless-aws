output "api_gateway_log_group_name" {
  description = "The name of the CloudWatch log group for API Gateway"
  value       = var.enable_api_gateway_logs ? aws_cloudwatch_log_group.api_gateway[0].name : null
}

output "lambda_log_group_names" {
  description = "Map of Lambda function names and their CloudWatch log group names"
  value       = var.enable_lambda_logs ? { for name, log_group in aws_cloudwatch_log_group.lambda : name => log_group.name } : null
}

output "fargate_log_group_names" {
  description = "Map of Fargate service names and their CloudWatch log group names"
  value       = var.enable_fargate_logs ? { for name, log_group in aws_cloudwatch_log_group.fargate : name => log_group.name } : null
}

output "api_gateway_alarm_arn" {
  description = "ARN of the API Gateway 5XX errors alarm (if created)"
  value       = var.enable_api_gateway_logs && var.create_basic_alarms ? aws_cloudwatch_metric_alarm.api_gateway_5xx[0].arn : null
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard (if created)"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_arn : null
}