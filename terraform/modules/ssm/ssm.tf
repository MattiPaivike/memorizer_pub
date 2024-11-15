resource "aws_ssm_parameter" "ssm_parameter" {
  name  = "${var.prefix}-${var.name}"
  type  = "SecureString"
  value = var.value

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}