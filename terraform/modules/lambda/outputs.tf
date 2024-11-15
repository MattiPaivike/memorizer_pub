output "lambda_function_name" {
  value = aws_lambda_function.lambda_func.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.lambda_func.arn
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.lambda_log_group.name
}

output "iam_role_name" {
  value = aws_iam_role.iam_for_lambda.name
}