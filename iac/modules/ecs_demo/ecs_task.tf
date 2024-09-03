#-------------------------------------------------------------------------------
# ECS Task which handle ai image generation.
#-------------------------------------------------------------------------------

locals {
  ecs_demo_task_id = "${local.id}-task"
}

resource "aws_ecs_task_definition" "ecs_demo_task" {
  family = local.ecs_demo_task_id

  task_role_arn            = aws_iam_role.ecs_demo_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_demo_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name      = "ai-image"
      image     = "${aws_ecr_repository.ecs_demo_task.repository_url}:6"
      cpu       = 512
      memory    = 1024
      essential = true

      environment = [
        {
          name : "PLACEHOLDER",
          value : "REPLACE_IF_WE_NEED_REAL_ENV"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_demo_task.name,
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  # lifecycle {
  #   ignore_changes = [
  #     # Ignore container_definitions b/c this will be managed by CodePipeline
  #     container_definitions,
  #   ]
  # }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "ecs_demo_task" {

  name = "/ecs/${aws_ecr_repository.ecs_demo_task.name}"

  tags = local.tags
}

resource "aws_ecr_repository" "ecs_demo_task" {
  name                 = local.ecs_demo_task_id
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "ecs_demo_task_execution_role" {
  name = "${local.ecs_demo_task_id}-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_demo_task_execution_role_attach" {
  role       = aws_iam_role.ecs_demo_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_demo_task_role" {
  name = "${local.ecs_demo_task_id}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "ecs_demo_task_role" {
  name        = "${local.ecs_demo_task_id}-role-main"
  description = "Additional permissions for ECS task application"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # TODO This is a placeholder statement.
      # It should be removed after adding the first necessary statement
      {
        "Sid" : "ListObjectsInBucket",
        "Effect" : "Allow",
        "Action" : ["s3:ListAllMyBuckets"],
        "Resource" : ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_demo_task_role" {
  role       = aws_iam_role.ecs_demo_task_role.name
  policy_arn = aws_iam_policy.ecs_demo_task_role.arn
}

resource "aws_security_group" "ecs_demo_task" {
  name        = local.ecs_demo_task_id
  description = "Egress-only security group for ${local.ecs_demo_task_id}"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}
