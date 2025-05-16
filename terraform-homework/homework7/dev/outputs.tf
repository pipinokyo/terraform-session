output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.vpc.nat_gateway_ip
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.asg.asg_name
}

output "application_url" {
  description = "URL to access the web application"
  value       = "https://${var.domain_name}"
}

# output "hosted_zone_id" {
#   description = "ID of the Route53 hosted zone"
#   value       = module.acm_route53.hosted_zone_id
# }