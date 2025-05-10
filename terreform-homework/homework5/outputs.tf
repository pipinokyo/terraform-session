# output "vpc_id" {
#   description = "The ID of the VPC"
#   value       = aws_vpc.app_vpc1.id
# }

# output "public_subnet_ids" {
#   description = "List of public subnet IDs"
#   value       = aws_subnet.app_pub_subnet[*].id
# }

# output "private_subnet_ids" {
#   description = "List of private subnet IDs"
#   value       = aws_subnet.app_priv_subnet[*].id
# }

# output "ec2_instance_public_ip" {
#   description = "Public IP address of the EC2 instance"
#   value       = try(aws_instance.main.public_ip, "Not assigned")
#   depends_on  = [aws_instance.main]
# }
# output "ec2_instance_id" {
#   description = "ID of the EC2 instance"
#   value       = aws_instance.main.id
# }

# output "security_group_id" {
#   description = "ID of the security group attached to the EC2 instance"
#   value       = aws_security_group.main.id
# }

# output "nat_gateway_ip" {
#   description = "Public IP of the NAT Gateway"
#   value       = aws_eip.nat_eip.public_ip
# }

# output "application_url" {
#   description = "URL to access the web application"
#   value       = try("http://${aws_instance.main.public_ip}", "Instance has no public IP")
# }

# output "alb_dns_name" {
#   description = "The DNS name of the ALB"
#   value       = aws_lb.app_alb.dns_name
# }

# output "target_group_arn" {
#   description = "ARN of the target group"
#   value       = aws_lb_target_group.app_tg.arn
# }

# output "launch_template_id" {
#   description = "ID of the launch template"
#   value       = aws_launch_template.app_lt.id
# }

# output "asg_name" {
#   description = "Name of the Auto Scaling Group"
#   value       = aws_autoscaling_group.app_asg.name
# }