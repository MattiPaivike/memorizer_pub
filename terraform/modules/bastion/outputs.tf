output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_instance_ip" {
  description = "Public IP address of the bastion instance"
  value       = aws_eip.bastion_public_ip.public_ip
}

output "bastion_iam_role" {
  description = "IAM role associated with the bastion instance"
  value       = aws_iam_role.instance_connect.name
}

output "bastion_instance_profile" {
  description = "Instance profile name for the bastion"
  value       = aws_iam_instance_profile.instance_connect.name
}
