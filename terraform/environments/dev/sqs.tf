module "sqs" {
  source              = "../../modules/sqs"
  sqs_queue_name      = "dev-memorizer"
  lambda_function_arn = module.lambda.lambda_function_arn
}