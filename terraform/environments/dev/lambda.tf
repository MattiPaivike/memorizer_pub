module "lambda" {
  source                   = "../../modules/lambda"
  lambda_name              = "memorizer-consumer"
  environment_name         = "dev"
  subnet_ids               = module.subnet.private_subnet_ids
  lambda_image_uri         = "${data.terraform_remote_state.common.outputs.consumer_ecr_repository_url}"
  lambda_image_tag         = "latest"
  lambda_security_group_id = module.lambda_sg.security_group_id
  ssm_parameter_arns = {
    db_host                                       = module.ssm_db_host.ssm_parameter_arn
    db_pass                                       = module.ssm_db_pass.ssm_parameter_arn
    db_username                                   = module.ssm_db_username.ssm_parameter_arn
    db_name                                       = module.ssm_db_name.ssm_parameter_arn
    open_ai_api_key                               = module.ssm_open_ai_api_key.ssm_parameter_arn
    openai_api_version                            = module.ssm_openai_api_version.ssm_parameter_arn
    openai_completion_model_deployment_name       = module.ssm_openai_completion_model_deployment_name.ssm_parameter_arn
    openai_function_calling_model_deployment_name = module.ssm_openai_function_calling_model_deployment_name.ssm_parameter_arn
    azure_openai_api_base_url                     = module.ssm_azure_openai_api_base_url.ssm_parameter_arn
  }
  sqs_queue_arns = {
    queue             = module.sqs.sqs_queue_arn
    dead_letter_queue = module.sqs.sqs_deadletter_arn
  }
  vpc_id = data.terraform_remote_state.common.outputs.vpc_id
}