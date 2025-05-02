resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecs_task_definition" "task_family" {
  family                   = "${var.project_name}-task_family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = var.ecs_tasks_execution_role_arn
  task_role_arn            = var.ecs_tasks_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-cont"
      image     = var.repository_url
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = var.log_group_name
          awslogs-region = var.region
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_family.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.public_subnet_az1_id, var.public_subnet_az2_id]
    security_groups  = [var.alb_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "${var.project_name}-cont"
    container_port   = 80
  }

  depends_on = [aws_ecs_task_definition.task_family]
}
