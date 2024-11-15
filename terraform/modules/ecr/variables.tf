variable "repository_name" {
  description = "Name of the ECR repository to create"
  type        = string
}

variable "enable_image_scanning" {
  description = "Enable image scanning on push"
  type        = bool
  default     = false
}
