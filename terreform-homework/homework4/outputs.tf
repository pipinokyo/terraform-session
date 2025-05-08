output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.app_vpc1.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.app_pub_subnet[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.app_priv_subnet[*].id
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = try(aws_instance.main.public_ip, "Not assigned")
  depends_on  = [aws_instance.main]
}
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "security_group_id" {
  description = "ID of the security group attached to the EC2 instance"
  value       = aws_security_group.main.id
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}

output "application_url" {
  description = "URL to access the web application"
  value       = try("http://${aws_instance.main.public_ip}", "Instance has no public IP")
}