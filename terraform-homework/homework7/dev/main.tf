module "vpc" {
  source = "../../../modules/vpc"

  vpc_cidr_block        = "10.0.0.0/16"
  public_subnets_cidrs  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  env                  = var.env
  common_tags          = local.common_tags
}

module "acm_route53" {
  source = "../../../modules/acm_route53"

  domain_name    = var.domain_name
  env           = var.env
  alb_dns_name   = module.alb.alb_dns_name
  alb_zone_id   = module.alb.alb_zone_id
  common_tags   = local.common_tags
  zone_id       = var.zone_id
}

module "alb" {
  source = "../../../modules/alb"

  env              = var.env
  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = module.acm_route53.certificate_arn
  common_tags      = local.common_tags
}

module "asg" {
  source = "../../../modules/asg"

  env                  = var.env
  instance_type        = var.instance_type
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn     = module.alb.target_group_arn
  common_tags          = local.common_tags
}