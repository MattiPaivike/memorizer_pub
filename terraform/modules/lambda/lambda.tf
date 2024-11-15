resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_func.function_name}"
  retention_in_days = 60
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name = "${var.environment_name}-lambda-policy-${var.lambda_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
          "Effect": "Allow",
          "Action": [
            "sqs:DeleteMessage",
            "sqs:ChangeMessageVisibility",
            "sqs:ReceiveMessage",
            "sqs:TagQueue",
            "sqs:UntagQueue",
            "sqs:PurgeQueue",
            "sqs:ListQueues",
            "sqs:GetQueueUrl",
            "sqs:GetQueueAttributes"
          ],
          "Resource": "${var.sqs_queue_arns["queue"]}"
      },
      {
          "Effect": "Allow",
          "Action": [
            "sqs:SendMessage",
            "sqs:DeleteMessage",
            "sqs:ChangeMessageVisibility",
            "sqs:ReceiveMessage",
            "sqs:TagQueue",
            "sqs:UntagQueue",
            "sqs:PurgeQueue",
            "sqs:ListQueues",
            "sqs:GetQueueUrl"
          ],
          "Resource": "${var.sqs_queue_arns["dead_letter_queue"]}"
      },
      {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "${aws_cloudwatch_log_group.lambda_log_group.arn}*"
      },
      {
        "Effect": "Allow",
        "Action": [
            "ssm:GetParameters",
            "ssm:GetParameter"
        ],
        "Resource": [
          "${var.ssm_parameter_arns["db_host"]}",
          "${var.ssm_parameter_arns["db_name"]}",
          "${var.ssm_parameter_arns["db_username"]}",
          "${var.ssm_parameter_arns["open_ai_api_key"]}",
          "${var.ssm_parameter_arns["db_pass"]}",
          "${var.ssm_parameter_arns["openai_api_version"]}",
          "${var.ssm_parameter_arns["openai_completion_model_deployment_name"]}",
          "${var.ssm_parameter_arns["openai_function_calling_model_deployment_name"]}",
          "${var.ssm_parameter_arns["azure_openai_api_base_url"]}"
        ]
      }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "aws_lambda_policy_attach_reader" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_lambda_policy_attach_vpc" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.environment_name}-iam-for-lambda-${var.lambda_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_lambda_function" "lambda_func" {
  image_uri     = "${var.lambda_image_uri}:${var.lambda_image_tag}"
  function_name = "${var.environment_name}-${var.lambda_name}"
  role          = aws_iam_role.iam_for_lambda.arn
  package_type  = "Image"
  timeout       = 200

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      DEBUG                                                  = 0
      LOCAL_EXECUTION                                        = 0
      OPENAI_API_TYPE                                        = "openai"
      DB_HOST_SSM_NAME                                       = var.ssm_parameter_arns["db_host"]
      DB_PASS_SSM_NAME                                       = var.ssm_parameter_arns["db_pass"]
      DB_USER_SSM_NAME                                       = var.ssm_parameter_arns["db_username"]
      DB_NAME_SSM_NAME                                       = var.ssm_parameter_arns["db_name"]
      OPENAI_API_KEY_SSM_NAME                                = var.ssm_parameter_arns["open_ai_api_key"]
      OPENAI_API_VERSION_SSM_NAME                            = var.ssm_parameter_arns["openai_api_version"]
      OPENAI_COMPLETION_MODEL_DEPLOYMENT_NAME_SSM_NAME       = var.ssm_parameter_arns["openai_completion_model_deployment_name"]
      OPENAI_FUNCTION_CALLING_MODEL_DEPLOYMENT_NAME_SSM_NAME = var.ssm_parameter_arns["openai_function_calling_model_deployment_name"]
      AZURE_OPENAI_API_BASE_URL_SSM_NAME                     = var.ssm_parameter_arns["azure_openai_api_base_url"]
    }
  }
}