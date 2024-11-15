output "sqs_queue_arn" {
  description = "ARN of the main SQS queue"
  value       = aws_sqs_queue.sqs_queue.arn
}

output "sqs_queue_id" {
  description = "ID of the main SQS queue"
  value       = aws_sqs_queue.sqs_queue.id
}

output "sqs_deadletter_arn" {
  description = "ARN of the dead-letter SQS queue"
  value       = aws_sqs_queue.sqs_deadletter.arn
}

output "lambda_event_source_mapping_id" {
  description = "ID of the Lambda event source mapping"
  value       = aws_lambda_event_source_mapping.sqs_queue_trigger.id
}
