output "app_record_name" {
  description = "The name of the Route53 record for the application"
  value       = aws_route53_record.app.name
}

output "zone_id" {
  description = "The Route53 zone ID"
  value       = data.aws_route53_zone.primary.zone_id
}
