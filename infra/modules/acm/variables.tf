variable "domain_name" {
  description = "The main domain for the cert "
  type        = string
  default     = "isaiahmichael.com"
}



variable "validation_method" {
  description = "How to prove domain ownership (DNS or EMAIL)"
  type        = string
  default     = "DNS"
}

