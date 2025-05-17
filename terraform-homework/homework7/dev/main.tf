module "network" {
  source = "../../../modules/network"

  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  tags                = local.common_tags
}

module "security_groups" {
  source = "../../../modules/security_groups"

  vpc_id = module.network.vpc_id
  tags   = local.common_tags
}

module "acm" {
  source = "../../../modules/acm"

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  tags                      = local.common_tags
}

module "alb" {
  source = "../../../modules/alb"

  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_sg_id
  acm_certificate_arn  = module.acm.certificate_arn
  short_name           = local.short_name  # Add this line
  tags                 = local.common_tags
}
module "asg" {
  source = "../../../modules/asg"

  ami_id               = data.aws_ami.amazon_linux_2.id
  instance_type        = var.instance_type
  ec2_security_group_id = module.security_groups.ec2_sg_id
  private_subnet_ids   = module.network.private_subnet_ids
  target_group_arn     = module.alb.target_group_arn
  tags                 = local.common_tags
}

module "route53" {
  source = "../../../modules/route53"

  hosted_zone_id = var.zone_id
  domain_name    = var.domain_name
  alb_dns_name   = module.alb.alb_dns_name
  alb_zone_id    = module.alb.zone_id
  tags           = local.common_tags
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}