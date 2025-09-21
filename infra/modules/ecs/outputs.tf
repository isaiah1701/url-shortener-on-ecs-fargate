output "cluster_name" {
  value = aws_ecs_cluster.this.name
}
output "task_definition_arn" {
  value = aws_ecs_cluster.this.name
}
output "service_name" {
  value = aws_ecs_service.this.name
}

output "private_subnet_ids" {
  value = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}


output "ecs_tasks_sg_id" {
  value = aws_security_group.ecs_tasks.id
}