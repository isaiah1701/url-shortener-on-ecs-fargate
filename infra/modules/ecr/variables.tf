variable "name" {}
variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE"
  type        = string
  default     = "IMMUTABLE"
}
variable "scan_on_push" {
  description = "ecr image scanning"

  type    = string
  default = "true"
}

variable "force_delete" {
  type    = bool
  default = "true"
}