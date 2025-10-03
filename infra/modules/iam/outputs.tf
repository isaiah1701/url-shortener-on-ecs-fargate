


output "execution_role_arn" {
  description = "IAM role ARN for ECS task execution (ECR pull + logs)"
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "IAM role ARN for the application container"
  value       = aws_iam_role.task.arn
}
output "codedeploy_role_name" {
  description = "The name of the IAM role used by CodeDeploy"
  value       = aws_iam_role.codedeploy.name
}

output "codedeploy_role_arn" {
  description = "The ARN of the IAM role used by CodeDeploy"
  value       = aws_iam_role.codedeploy.arn
}
output "gha_role_arn" {
  value = aws_iam_role.gha_oidc.arn
}

