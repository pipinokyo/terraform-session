output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.app_tg.arn
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.app_lb.arn
}

output "zone_id" {
  description = "The zone ID of the load balancer"
  value       = aws_lb.app_lb.zone_id
}