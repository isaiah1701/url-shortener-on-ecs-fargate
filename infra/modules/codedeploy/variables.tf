variable "iam_role_arn" {
  type = string
}
variable "cluster" {
  type = string
}

variable "ecs_svc" {
  type = string
}
variable "listener_arn" {
  description = "ARN of the production ALB listener used by CodeDeploy"
  type        = string
}

variable "blue_tg_name" {
  description = "Name of the blue target group"
  type        = string
}

variable "green_tg_name" {
  description = "Name of the green target group"
  type        = string
}

variable "task_definition_arn" {
  description = "ARN of the ECS task definition"
  type        = string
}

variable "container_name" {
  description = "Name of the container in the task definition"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository to monitor for pushes"
  type        = string
}
variable "taskdef_family" {
  description = "The ECS task definition family name (e.g. urlshortener)"
  type        = string
}

variable "task_role_arn" {
  description = "The IAM role ARN to use as the ECS task role"
  type        = string
}

variable "execution_role_arn" {
  description = "The IAM role ARN to use as the ECS execution role"
  type        = string
}

variable "container_repo_uri" {
  description = "The full ECR repository URI (without tag) used for the container image"
  type        = string
}
