variable "endpoints" {
  type = map(object({
    service_name      = string           
    vpc_endpoint_type = string              # "Gateway" (for S3/DynamoDB)
  
    route_table_ids   = optional(list(string), [])
  }))
}

variable "vpc_id" {
  type = string

}
variable "region" {
  type= string
}
#variable "route_table_ids" { type = list(string) }
variable "internet_gateway_id" {
  type= string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

