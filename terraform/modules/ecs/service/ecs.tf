resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = var.log_group_path
  retention_in_days = 7
  tags = {
    Environment = "${var.env}"
  }
}

resource "aws_ecs_task_definition" "this" {
    family                              = "task-${var.app_name}"
    container_definitions               = templatefile("${var.container_definitions_path}", { container_port = var.container_port})
    
    requires_compatibilities            = ["FARGATE"]
    network_mode                        = "awsvpc"
    cpu                                 = "256"
    memory                              = "512"
    execution_role_arn                  = aws_iam_role.ecsTaskExecutionRole.arn
    task_role_arn                       = aws_iam_role.ecsTaskRole.arn
    lifecycle {
      ignore_changes = [
        container_definitions
      ]
    }
}


resource "aws_ecs_service" "this" {
    name                                = "${var.service_name}"
    cluster                             = "${var.cluster_arn}"
    task_definition                     = aws_ecs_task_definition.this.arn
    launch_type                         = "FARGATE"
    scheduling_strategy                 = "REPLICA"
    desired_count                       = 2
    enable_execute_command = true
  network_configuration {
    subnets                             = var.subnet_ids_priv
    assign_public_ip                    = false
    security_groups                     = [aws_security_group.ecs_sg.id, var.alb_sg_id]
  }

  load_balancer {
    target_group_arn                    = var.target_group_arn
    container_name                      = "${var.container_name}"
    container_port                      = var.container_port
  }
  lifecycle {
  ignore_changes = [
    task_definition
  ]
  }
  
  depends_on                            = [var.listener]
}
