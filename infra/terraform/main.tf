provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"
  vpc_cidr = "10.1.0.0/16"
}

module "ecr" {
  source = "./modules/ecr"
  repository_name = "higuchi-pr"
}

module "alb" {
  source             = "./modules/alb"
  name               = "higuchi-pr"
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  certificate_arn    = module.acm.certificate_arn
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id             = module.network.vpc_id
  subnets            = module.network.public_subnet_ids
  higuchi_pr_ecs_sg_id          = module.network.higuchi_pr_ecs_sg_id
  container_image    = "${module.ecr.repository_url}:latest"
  execution_role_arn = "arn:aws:iam::082032435474:role/ecsTaskExecutionRole"
  alb_target_group_arn = module.alb.alb_target_group_arn
  log_group_name   = "/ecs/higuchi-pr-ecs"
  log_retention_days = 7
  aws_region = var.region
}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
  sub_domain_name = var.sub_domain_name
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
}

module "acm" {
  source         = "./modules/acm"
  domain_name    = var.domain_name
  sub_domain_name = var.sub_domain_name
  zone_id = module.route53.zone_id
}

module "dynamodb" {
  source         = "./modules/dynamodb"
}