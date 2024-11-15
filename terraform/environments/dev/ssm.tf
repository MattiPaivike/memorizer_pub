# root module - calling ssm module
module "ssm_django_secret_key" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "django-secret-key"
  value  = random_password.django_secret_key.result
}

module "ssm_django_allowed_hosts" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "django-allowed-hosts"
  value  = "${var.subdomain_name}.${var.domain_name}"
}

module "ssm_open_ai_api_key" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "openai-api-key"
  value  = "temp"
}

module "ssm_azure_openai_api_base_url" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "azure-openai-api-base-url"
  value  = "temp"
}

module "ssm_openai_api_version" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "openai-api-version"
  value  = "temp"
}

module "ssm_openai_completion_model_deployment_name" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "openai-model-completion-deployment-name"
  value  = "gpt-4o-mini"
}

module "ssm_openai_function_calling_model_deployment_name" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "openai-model-function-calling-deployment-name"
  value  = "gpt-4o-mini"
}

module "ssm_db_pass" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "db-password"
  value  = module.rds.db_password
}

module "ssm_db_host" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "db-host"
  value  = module.rds.db_address
}

module "ssm_db_username" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "db-username"
  value  = module.rds.db_username
}

module "ssm_db_name" {
  source = "../../modules/ssm"
  prefix = var.prefix
  name   = "db-name"
  value  = module.rds.db_name
}

variable "prefix" {
  description = "Prefix for parameter names"
  type        = string
  default     = "dev-memorizer"
}

# root module - random password resources
resource "random_password" "django_secret_key" {
  length           = 16
  special          = true
  override_special = "_!%^"
}