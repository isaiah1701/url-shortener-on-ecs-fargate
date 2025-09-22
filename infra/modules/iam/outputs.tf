


output "execution_role_arn" {
  description = "IAM role ARN for ECS task execution (ECR pull + logs)"
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "IAM role ARN for the application container"
  value       = aws_iam_role.task.arn
}
