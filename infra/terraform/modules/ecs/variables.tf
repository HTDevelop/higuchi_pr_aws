variable "vpc_id" {}
variable "subnets" { type = list(string) }
variable "higuchi_pr_ecs_sg_id" {}
variable "container_image" {}
variable "execution_role_arn" {
  type        = string
}
variable "alb_target_group_arn" {
    type        = string
}
variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name"
}

variable "log_retention_days" {
  type        = number
  default     = 7
}

variable "log_stream_prefix" {
  type        = string
  default     = "ecs"
}

variable "aws_region" {}