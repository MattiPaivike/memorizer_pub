variable "sqs_queue_name" {
  description = "Prefix for naming resources"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to trigger"
  type        = string
}

variable "dead_letter_retention_seconds" {
  description = "Message retention time for dead letter queue"
  type        = number
  default     = 1209600
}

variable "sqs_receive_wait_time" {
  description = "Wait time for receiving messages in the SQS queue"
  type        = number
  default     = 20
}

variable "sqs_visibility_timeout" {
  description = "Visibility timeout for the SQS queue"
  type        = number
  default     = 200
}

variable "max_receive_count" {
  description = "Maximum receive count for dead-letter redrive policy"
  type        = number
  default     = 2
}

variable "batch_size" {
  description = "Batch size for Lambda event source mapping"
  type        = number
  default     = 10
}