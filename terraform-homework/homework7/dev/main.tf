module "network" {                                                                      
  source = "../../../modules/network"                                             # Path to network module

  vpc_cidr            = "10.0.0.0/16"                                             # VPC IP range
  public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]             # Public subnet IP ranges (ALB).
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]            # Private subnet IP ranges (ASG).
  tags                = local.common_tags                                         # Common tags for resources
}

module "security_groups" {                                                        # Security groups module
  source = "../../../modules/security_groups"                                     # Path to security groups module

  vpc_id = module.network.vpc_id                                                  # Gets VPC ID from network module output
  tags   = local.common_tags                                                      # Common tags for resources
}

module "acm" {                                                                   # ACM module. 
  source = "../../../modules/acm"                                                # Path to ACM module

  domain_name               = var.domain_name                                    # Domain name for the ACM certificate:machtap.com
  subject_alternative_names = var.subject_alternative_names                      # Subject alternative names for the ACM certificate: ["www.machtap.com"]
  tags                      = local.common_tags                                  # Common tags for resources
}

module "alb" {                                                                   # ALB module
  source = "../../../modules/alb"                                                # Path to ALB module

  vpc_id               = module.network.vpc_id                                   # Gets VPC ID from network module output
  public_subnet_ids    = module.network.public_subnet_ids                        # Gets public subnet IDs from network module output 
  alb_security_group_id = module.security_groups.alb_sg_id                       # Gets ALB security group ID from security groups module output 
  acm_certificate_arn  = module.acm.certificate_arn                              # Gets ACM certificate ARN from ACM module output
  short_name           = local.short_name                                        # Short name for resources( specified in locals.tf because some resources have long names cant be more than 32.)
  tags                 = local.common_tags                                       # Common tags for resources
}
module "asg" {                                                                   # ASG module
  source = "../../../modules/asg"                                                # Path to ASG module

  ami_id               = data.aws_ami.amazon_linux_2.id                          # Gets the latest Amazon Linux 2 AMI ID
  instance_type        = var.instance_type                                       # Instance type for the EC2 instances (t2.micro) variable defined in variables.tf
  ec2_security_group_id = module.security_groups.ec2_sg_id                       # Security group for instances. Gets EC2 security group ID from security groups module output
  private_subnet_ids   = module.network.private_subnet_ids                       # Private subnets for instances. Gets private subnet IDs from network module output
  target_group_arn     = module.alb.target_group_arn                             # ALB target group ARN. Gets target group ARN from ALB module output
  tags                 = local.common_tags                                       # Common tags for resources
}

module "route53" {                                                               # Route53 module
  source = "../../../modules/route53"                                            # Path to Route53 module  

  hosted_zone_id = var.zone_id                                                   # Hosted zone ID for Route53 
  domain_name    = var.domain_name                                               # Domain name for Route53 machtap.com
  alb_dns_name   = module.alb.alb_dns_name                                       # ALB DNS name (output from ALB module)
  alb_zone_id    = module.alb.zone_id                                            # ALB hosted zone ID (output from ALB module)
  tags           = local.common_tags                                             # Common tags for resources
}

data "aws_ami" "amazon_linux_2" {                                                # Fetches the latest Amazon Linux 2 AMI: Data source to get the latest Amazon Linux 2 AMI
  most_recent = true                                                             # Get the most recent AMI   
  owners      = ["amazon"]                                                       # Owner of the AMI (Amazon)  

  filter {                                                                       # Filter to find the Amazon Linux 2 AMI 
    name   = "name"                                                              # Filter by name
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]                                      # AMI name pattern (HVM virtualization, x86_64, EBS-backed).
  } 
}