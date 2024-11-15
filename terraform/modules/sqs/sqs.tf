resource "aws_sqs_queue" "sqs_queue" {
  name                       = "${var.sqs_queue_name}-queue"
  receive_wait_time_seconds  = var.sqs_receive_wait_time
  visibility_timeout_seconds = var.sqs_visibility_timeout
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_deadletter.arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_sqs_queue" "sqs_deadletter" {
  name                      = "${var.sqs_queue_name}dlq"
  message_retention_seconds = var.dead_letter_retention_seconds
}

resource "aws_lambda_event_source_mapping" "sqs_queue_trigger" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  function_name    = var.lambda_function_arn
  batch_size       = var.batch_size
}