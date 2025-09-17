variable "role_name" {
  description = "Name of the IAM role (e.g., dev-urlshortener-task)"
  type        = string
}

variable "principal_service" {
  description = "AWS service that will assume the role "
  type        = string
  default     = "ecs-tasks.amazonaws.com"
}

variable "policy_statements" {
  description = "Inline policy statements to attach to the role"
  type = list(object({
    actions   = list(string) # e.g., ["dynamodb:GetItem","dynamodb:PutItem"]
    resources = list(string) # e.g., [module.ddb.table_arn]
    effect    = optional(string, "Allow")
  }))
  default = []
}

variable "managed_policy_arns" {
  description = "Optional AWS managed policy ARNs to attach (e.g., CloudWatchLogsFullAccess)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for the role and inline policy"
  type        = map(string)
  default     = {}
}
