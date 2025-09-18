variable "endpoints" {
  type = map(string)
}
variable "security_group_ids" {
    type = list(string)
}

variable "vpc_id"{
    type = string 
  
}