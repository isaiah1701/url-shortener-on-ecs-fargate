# ALB SG
resource "aws_security_group" "alb" {
  name        = "${var.sg_name}-alb-sg"
  vpc_id      = var.vpc_id
  description = "ALB SG"

}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}


resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTPS from anywhere"
}


resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}



# ECS Tasks SG
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.sg_name}-ecs-sg"
  vpc_id      = var.vpc_id
  description = "ECS tasks SG"

}

resource "aws_security_group_rule" "ecs_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 8080 # 8080 default
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id # <- ALB SG as source
  security_group_id        = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "ecs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_tasks.id
}


#ecr sg 

resource "aws_security_group" "interface_sg" {
  name        = "${var.sg_name}-ecr-sg"
  vpc_id      = var.vpc_id
  description = "security group for ecr endpoints "

}

resource "aws_security_group_rule" "interface_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_tasks.id
  security_group_id        = aws_security_group.interface_sg.id


}

resource "aws_security_group_rule" "interface_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.interface_sg.id
}
