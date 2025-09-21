variable "name" {}
variable "cidr_block" {}
variable "azs" { type = list(string) }
variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}

}
