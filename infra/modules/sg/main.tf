resource "aws_security_group" "this" {
  name        = var.name
  description = "SG for ECS tasks"
  vpc_id      = var.vpc_id
  tags        = var.tags
}


resource "aws_security_group_rule" "ingress_from_alb" {

  type                     = "ingress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = var.alb_sg_id

  security_group_id = aws_security_group.this.id


}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
  description       = "All outbound"
}
