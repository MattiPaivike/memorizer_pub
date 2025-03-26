resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"

}

resource "aws_iam_policy" "task_execution_app_role_policy" {
  name = "${var.prefix}-ecs-task-app-execution-role-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": "sqs:SendMessage",
          "Resource": "${var.sqs_queue_arn}"
      }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "task_app_execution_role" {
  role       = aws_iam_role.app_iam_role.name
  policy_arn = aws_iam_policy.task_execution_app_role_policy.arn
}

resource "aws_iam_policy" "task_execution_role_policy" {
  name = "${var.prefix}-ecs-task-execution-role-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "sqs:SendMessage",
        "Resource" : var.sqs_queue_arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource" : var.ssm_parameter_arns
      }
    ]
  })
}


resource "aws_iam_role" "task_execution_role" {
  name = "iam-ecs-task-execution-role-${var.prefix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_role" "app_iam_role" {
  name               = "epicmemory-ecs-task-role-${terraform.workspace}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF  

}

resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${var.prefix}-django-logs"

}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.prefix}-django"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.app_iam_role.arn

  container_definitions = jsonencode([
    {
      "name" : "api",
      "image" : "${var.ecr_repository_url_django}:${var.django_ecr_tag}",
      "cpu" : 512,
      "memory" : 1024,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 9000,
          "hostPort" : 9000
        }
      ],
      "mountPoints" : [
        {
          "readOnly" : false,
          "containerPath" : "/vol/web",
          "sourceVolume" : "static"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${aws_cloudwatch_log_group.ecs_task_logs.name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "api"
        }
      },
      "secrets" : [
        for key, value in var.service_secrets : {
          "name"      : key,
          "valueFrom" : value
        }
      ],
      "environment" : [
        {
          "name" : "SQS_URL",
          "value" : "${var.sqs_queue_id}"
        },
        {
          "name" : "DEBUG",
          "value" : "1"
        },
        {
          "name" : "LOCAL_EXECUTION",
          "value" : "0"
        }
      ]
    },
    {
      "name" : "proxy",
      "image" : "${var.ecr_repository_url_nginx}:${var.nginx_ecr_tag}",
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 8000,
          "hostPort" : 8000
        }
      ],
      "cpu" : 512,
      "memory" : 1024,
      "environment" : [
        {
          "name" : "APP_HOST",
          "value" : "127.0.0.1"
        },
        {
          "name" : "APP_PORT",
          "value" : "9000"
        },
        {
          "name" : "LISTEN_PORT",
          "value" : "8000"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${aws_cloudwatch_log_group.ecs_task_logs.name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "proxy"
        }
      },
      "mountPoints" : [
        {
          "readOnly" : true,
          "containerPath" : "/vol/web",
          "sourceVolume" : "static"
        }
      ]
    }
  ])

  volume {
    name = "static"
  }
}

resource "aws_ecs_task_definition" "batch_job" {
  family                   = "${var.prefix}-django-batch"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn           = aws_iam_role.app_iam_role.arn

  container_definitions = jsonencode([
    {
      "name" : "batch",
      "image" : "${var.ecr_repository_url_django}:${var.django_ecr_tag}",
      "cpu" : 1024,
      "memory" : 2048,
      "essential" : true,
      "mountPoints" : [
        {
          "readOnly" : false,
          "containerPath" : "/vol/web",
          "sourceVolume" : "static"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${aws_cloudwatch_log_group.ecs_task_logs.name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "batch"
        }
      },
      "secrets" : [
        for key, value in var.service_secrets : {
          "name"      : key,
          "valueFrom" : value
        }
      ],
      "environment" : [
        {
          "name" : "SQS_URL",
          "value" : "${var.sqs_queue_id}"
        },
        {
          "name" : "DEBUG",
          "value" : "1"
        },
        {
          "name" : "LOCAL_EXECUTION",
          "value" : "0"
        }
      ]
    }
  ])

  volume {
    name = "static"
  }
}

resource "aws_ecs_service" "api" {
  name            = "${var.prefix}-django"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
  }

  load_balancer {
    target_group_arn = var.load_balancer_target_group_arn
    container_name   = "proxy"
    container_port   = 8000
  }

}