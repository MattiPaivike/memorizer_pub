variable "prefix" {
  description = "Prefix for parameter names"
  type        = string
}

variable "name" {
  description = "Name of the SSM parameter (suffix only)"
  type        = string
}

variable "value" {
  description = "Value of the SSM parameter"
  type        = string
}