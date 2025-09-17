output "role_name" {
  value = aws_iam_role.this.name
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "inline_policy_arn" {
  value       = length(aws_iam_policy.inline) > 0 ? aws_iam_policy.inline[0].arn : null
  description = "ARN of the generated inline policy (if any)"
}
