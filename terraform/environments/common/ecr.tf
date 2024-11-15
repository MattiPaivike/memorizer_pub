module "ecr_django" {
  source          = "../../modules/ecr"
  repository_name = "memorizer-django"
}

module "ecr_consumer" {
  source          = "../../modules/ecr"
  repository_name = "memorizer-consumer"
}

module "ecr_nginx" {
  source          = "../../modules/ecr"
  repository_name = "memorizer-nginx"
}

output "django_ecr_repository_arn" {
  value = module.ecr_django.ecr_repository_arn
}

output "django_ecr_repository_url" {
  value = module.ecr_django.ecr_repository_url
}

output "consumer_ecr_repository_arn" {
  value = module.ecr_consumer.ecr_repository_arn
}

output "consumer_ecr_repository_url" {
  value = module.ecr_consumer.ecr_repository_url
}

output "nginx_ecr_repository_arn" {
  value = module.ecr_nginx.ecr_repository_arn
}

output "nginx_ecr_repository_url" {
  value = module.ecr_nginx.ecr_repository_url
}