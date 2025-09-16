variable "name" { type = string }
variable "container_image" { type = string }
variable "container_port" { type = number }
variable "cpu" { type = number }
variable "memory" { type = number }
variable "desired_count" { type = number }
variable "subnets_ids" { type = list(string) }
variable "security_groups_ids" { type = list(string) }
variable "assign_public_ip" { type = bool }
variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }
variable "launch_type" {}
variable "security_group_ids" { type = list(string) }