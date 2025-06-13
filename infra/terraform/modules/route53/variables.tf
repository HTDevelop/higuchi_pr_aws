variable "domain_name" {
  type        = string
  description = "The root domain name"
}

variable "sub_domain_name" {
  type = string
}

variable "alb_dns_name" {}

variable "alb_zone_id" {}