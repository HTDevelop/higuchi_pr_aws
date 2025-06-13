resource "aws_iam_role" "higuchi_pr_task_role" {
  name = "ecs-task-role-higuchi_pr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "higuchi_prpermissions" {
  name = "ecs-task-higuchi_pr-policy"
  role = aws_iam_role.higuchi_pr_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # CloudWatch Logs にログを出す（任意）
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:Query"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days
}

resource "aws_ecs_cluster" "this" {
  name = "higuchi-pr-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "higuchi-pr-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = aws_iam_role.higuchi_pr_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "web"
      image     = var.container_image
      portMappings = [
        {
          containerPort = 5000
          hostPort = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.log_stream_prefix
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "higuchi-pr-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = var.subnets
    security_groups = [var.higuchi_pr_ecs_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "web"
    container_port   = 5000
  }

}

