output "id" { value = aws_security_group.this.id }
output "arn" { value = aws_security_group.this.arn }
output "name" { value = aws_security_group.this.name }
output "ecs_tasks_sg_id" {
  value       = aws_security_group.this.id
  description = "SG ID for ECS tasks"
}
output "alb_sg_id"       { value = aws_security_group.alb.id }
output "ecs_tasks_sg_id" { value = aws_security_group.ecs_tasks.id }
