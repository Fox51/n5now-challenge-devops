resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecr_repository" "app_backend_repo" {
  name = "${var.ecr_repository_name}-backend"
}

resource "aws_ecr_repository" "app_frontend_repo" {
  name = "${var.ecr_repository_name}-frontend"
}

resource "aws_ecs_cluster" "app_cluster" {
  name = var.ecs_cluster_name
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.ecs_service_name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.task_family}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = <<DEFINITION
[
  {
    "name": "backend",
    "image": "${aws_ecr_repository.app_backend_repo.repository_url}:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 5000,
        "hostPort": 5000
      }
    ],
    "environment": [
      {
        "name": "FLASK_ENV",
        "value": "production"
      },
      {
        "name": "DEPLOYMENT_ENV",
        "value": "${var.deployment_env}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.ecs_service_name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "backend"
      }
    }
  },
  {
    "name": "frontend",
    "image": "${aws_ecr_repository.app_frontend_repo.repository_url}:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "environment": [
      {
        "name": "BACKEND_URL",
        "value": "http://backend:5000"
      }
    ],
    "dependsOn": [
      {
        "containerName": "backend",
        "condition": "START"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.ecs_service_name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "frontend"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "app_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_ecs_task_definition.app_task
  ]
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-security-group"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
