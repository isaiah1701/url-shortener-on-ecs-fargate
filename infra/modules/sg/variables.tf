variable "name" { type = string }
variable "vpc_id" { type = string }
variable "app_port" { type = number }
variable "alb_sg_id" { type = string }
variable "tags" {
  type = map(string)
}