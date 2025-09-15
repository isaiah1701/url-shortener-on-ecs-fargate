variable "name" {}
variable "cidr_block" {}
variable "azs" { type = list(string) }
variable "public_subnet_cidrs" {}
variable "private_subnet_cidrs" {}
variable "tags" {
  type    = map(string)
  default = {}

}
