resource "aws_ecs_cluster" "this" {

  name = "${var.ecs_name}-cluster"

}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/dev-urlshortener"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.ecs_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.ecs_name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "TABLE_NAME"
          value = var.table_name
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "appv2"
        }
      }
    }
  ])
}
data "aws_lb_target_group" "blue" {
  name = var.blue_tg_name
}


resource "aws_ecs_service" "this" {
  name            = "${var.ecs_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.blue.arn
    container_name   = var.ecs_name
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 30
  propagate_tags                    = "SERVICE"
  enable_execute_command            = true

  lifecycle {
    ignore_changes = [
      load_balancer,
      task_definition, # ignore new task_def arns from image pushes
      desired_count    # ignore changes if autoscaling adjusts replicas
    ]
  }
}