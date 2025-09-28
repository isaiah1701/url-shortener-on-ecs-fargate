output "cluster_name" {
  value = aws_ecs_cluster.this.name
}
output "task_definition_arn" {
  value = aws_ecs_cluster.this.name
}
output "service_name" {
  value = aws_ecs_service.this.name
}




output "ecs_log_group_name" {
  description = "CloudWatch log group name for ECS tasks"
  value       = aws_cloudwatch_log_group.ecs.name
}