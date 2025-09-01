resource "aws_security_group" "ecs_sg" {
    vpc_id                      = var.vpc_id
    name                        = "${var.app_name}-sg-ecs"
    description                 = "Security group for ecs app"
    revoke_rules_on_delete      = true
}

resource "aws_security_group_rule" "ecs_alb_ingress" {
    type                        = "ingress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    description                 = "Allow inbound traffic from ALB"
    security_group_id           = aws_security_group.ecs_sg.id
    source_security_group_id    = var.alb_sg_id
}

resource "aws_security_group_rule" "ecs_all_egress" {
    type                        = "egress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    description                 = "Allow outbound traffic from ECS"
    security_group_id           = aws_security_group.ecs_sg.id
    cidr_blocks                 = ["0.0.0.0/0"] 
}

