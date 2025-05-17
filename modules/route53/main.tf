resource "aws_route53_record" "alb_alias" {       # Creates a DNS record named "alb_alias" in Route 53 for the ALB.
  zone_id = var.hosted_zone_id                    # Specifies which Route 53 hosted zone to add this record to. 
  name    = var.domain_name                       # Domain name for the record. This is the domain name for the ALB. identified in variables.tf
  type    = "A"                                   # Creates an A record (address record) for IPv4

  alias {                                         # alias: Points domain to ALB (instead of IP). creates an alias record.
    name                   = var.alb_dns_name     # DNS name of the ALB. This is the DNS name of the ALB created in the load balancer module.
    zone_id                = var.alb_zone_id      # Hosted zone ID of the ALB. This is the hosted zone ID of the ALB created in the load balancer module.
    evaluate_target_health = true                 # Enables health checks - won't route to unhealthy ALBs.
  }
}

# # # Step-by-Step Flow # # #

# User enters var.domain_name in browser
# DNS query goes to Route 53
# Route 53 checks the ALB's health (if enabled)
# Route 53 returns the ALB's IP addresses
# User connects to the ALB
# ALB forwards request to your backend servers