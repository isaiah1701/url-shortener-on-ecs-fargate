resource "aws_ecs_cluster" "this" {

  name = "${var.name}-cluster"

}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn


  container_definitions = jsonencode([
    {
      name      = var.name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "this" {


    name = "${var.name}-service"
    cluster = aws_ecs_cluster.this.id 
    task_definition = aws_ecs_task_definition.this.arn 
    desired_count = var.desired_count
    launch_type = var.launch_type

    network_configuration {
      subnets = var.subnets_ids 
      security_groups = var.security_groups_ids 
      assign_public_ip = false
    }

}
