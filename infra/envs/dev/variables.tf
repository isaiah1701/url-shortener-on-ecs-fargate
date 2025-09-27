variable "environment" {
  description = "environment name"
  type        = string
}
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
}


variable "container_image" {
  description = "container image"
  type        = string

}


variable "dynamodb_table_arn" {
  type = string
}


variable "alb_sg_id" {
  type = string
}
variable "region" {
  type = string
}
variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}
variable "domain_name" {
  type = string
}
variable "cloudflare_zone_id" {
  type = string
}