variable "name" {
  type        = string
  description = "Name prefix"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "certificate_arn" {
  type        = string
  description = "ACM Certificate ARN"
}

variable "target_port" {
  type        = number
  default     = 5000
  description = "Port the target group forwards to"
}