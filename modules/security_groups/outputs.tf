output "alb_sg_id" {
  description = "The ID of the ALB Security Group"
  value       = aws_security_group.alb_sg.id
}

output "ec2_sg_id" {
  description = "The ID of the EC2 Security Group"
  value       = aws_security_group.ec2_sg.id
}