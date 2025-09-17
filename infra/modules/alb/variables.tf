variable "name" {
  description = "Base name (env-app)"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB"
}

variable "app_port" {
  type        = number
  description = "Container/app port exposed via target group"
  default     = 3000
}

variable "health_check_path" {
  type        = string
  description = "Health check path for target group"
  default     = "/health"
}

variable "certificate_arn" {
  type        = string
  description = "ACM cert ARN for HTTPS listener (eu-west-2 for you)"
}

variable "enable_deletion_protection" {
  type    = bool
  default = true
}

variable "idle_timeout" {
  type    = number
  default = 60
}

variable "tags" {
  type    = map(string)
  default = {}
}
