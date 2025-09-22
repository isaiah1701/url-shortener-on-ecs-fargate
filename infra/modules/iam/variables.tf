
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
variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table the app will access"
  type        = string
}
variable "iam_name" {
  description = "Base name/prefix (e.g. urlshortener-dev)"
  type        = string
}
