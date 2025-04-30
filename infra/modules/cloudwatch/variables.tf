variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# API Gateway variables
variable "enable_api_gateway_logs" {
  description = "Enable CloudWatch logs for API Gateway"
  type        = bool
  default     = true
}

variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = ""
}

variable "api_gateway_stage" {
  description = "API Gateway deployment stage"
  type        = string
  default     = "dev"
}

# Lambda variables
variable "enable_lambda_logs" {
  description = "Enable CloudWatch logs for Lambda functions"
  type        = bool
  default     = true
}

variable "lambda_function_names" {
  description = "List of Lambda function names"
  type        = list(string)
  default     = []
}

# Fargate variables
variable "enable_fargate_logs" {
  description = "Enable CloudWatch logs for ECS Fargate services"
  type        = bool
  default     = true
}

variable "fargate_cluster_name" {
  description = "Name of the ECS Fargate cluster"
  type        = string
  default     = ""
}

variable "fargate_service_names" {
  description = "List of ECS Fargate service names"
  type        = list(string)
  default     = []
}

# Log configuration
variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 3  # Keep retention very low to minimize costs
}

# Alarm and dashboard configuration
variable "create_basic_alarms" {
  description = "Create basic CloudWatch alarms"
  type        = bool
  default     = false  # Default to false to minimize costs
}

variable "create_dashboard" {
  description = "Create a CloudWatch dashboard"
  type        = bool
  default     = false  # Default to false to minimize costs
}

variable "dashboard_name" {
  description = "Name for the CloudWatch dashboard"
  type        = string
  default     = "pedidos-dashboard"
}