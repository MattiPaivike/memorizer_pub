# IAM Policy for ECR Read-Write Access
resource "aws_iam_policy" "ecr_rw_policy" {

  name        = "${var.account_name}_policy"
  description = "Read-Write access policy for ECR repositories, Lambda function container updates, and ECS actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:DeleteRepositoryPolicy",
          "ecr:ReplicateImage",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:UpdateFunctionCode"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM User (Service Account) for ECR Access
resource "aws_iam_user" "ecr_service_account" {
  name = var.account_name
}

# Attach Policy to the IAM User
resource "aws_iam_user_policy_attachment" "ecr_policy_attachment" {
  user       = aws_iam_user.ecr_service_account.name
  policy_arn = aws_iam_policy.ecr_rw_policy.arn
}