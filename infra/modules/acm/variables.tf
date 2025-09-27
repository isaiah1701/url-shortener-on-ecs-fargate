variable "domain_name" {
  description = "The main domain for the cert "
  type        = string
  default = "short.isaiahmichael.com"
}




variable "cloudflare_zone_id" {
  type = string
}