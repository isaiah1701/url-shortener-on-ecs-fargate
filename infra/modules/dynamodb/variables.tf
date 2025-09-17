variable "name" {
  description = "Table name (e.g., dev-urlshortener)"
  type        = string
}

variable "hash_key_name" {
  description = "Primary (partition) key name"
  type        = string
  default     = "slug"
}

variable "hash_key_type" {
  description = "Primary key type: S | N | B"
  type        = string
  default     = "S"
}

variable "billing_mode" {
  description = "PAY_PER_REQUEST (on-demand) or PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "ttl" {
  description = "Time-to-live config"
  type = object({
    enabled        = bool
    attribute_name = string
  })
  default = {
    enabled        = false
    attribute_name = ""
  }
}

variable "point_in_time_recovery" {
  description = "Enable PITR backups"
  type        = bool
  default     = true
}

variable "sse_enabled" {
  description = "Server-side encryption with AWS-owned key"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra resource tags"
  type        = map(string)
  default     = {}
}
