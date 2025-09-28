variable "ecs_name" {
  description = "Base name for ECS service/task"
  type        = string
  default     = "ecs"
}

variable "container_image" {
  description = "Container image URI (ECR or DockerHub)"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory (MB)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS tasks (usually private)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for ECS tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to ECS tasks"
  type        = bool
  default     = false
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN (for app access to AWS resources)"
  type        = string
}

variable "launch_type" {
  description = "ECS launch type"
  type        = string
  default     = "FARGATE"
}


variable "table_name" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "target_group" {
  type = string
}
variable "aws_region" {
  type = string 
}
