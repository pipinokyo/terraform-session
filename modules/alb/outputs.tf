output "alb_dns_name" {                                                 # Output the DNS name of the ALB  
  description = "The DNS name of the Application Load Balancer"         # Description of the output
  value       = aws_lb.app_lb.dns_name                                  # The DNS name of the ALB
}

output "target_group_arn" {                                             # Output the ARN of the target group
  description = "The ARN of the target group"                           # Description of the output 
  value       = aws_lb_target_group.app_tg.arn                          # The ARN of the target group
}

output "alb_arn" {                                                      # Output the ARN of the ALB
  description = "The ARN of the load balancer"                          # Description of the output
  value       = aws_lb.app_lb.arn                                       # The ARN of the ALB
} 

output "zone_id" {                                                      # Output the zone ID of the ALB
  description = "The zone ID of the load balancer"                      # Description of the output
  value       = aws_lb.app_lb.zone_id                                   # The zone ID of the ALB
}