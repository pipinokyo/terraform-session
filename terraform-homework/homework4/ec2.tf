resource "aws_security_group" "main" {
  name        = "${var.env}-security-group"
  description = "allow SSH and HTTP"
  vpc_id      = aws_vpc.app_vpc1.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.env}-security-group"
  }
}
# Creates a security group (virtual firewall) for the EC2 instance
# Named dynamically based on the env variable (like "dev-security-group")
# Attached to an existing VPC (aws_vpc.app_vpc1)
# Uses create_before_destroy lifecycle to prevent downtime during updates

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  count             = length(var.ingress_ports)
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = element(var.ingress_cidr, count.index)
  from_port         = element(var.ingress_ports, count.index)
  ip_protocol       = "tcp"
  to_port           = element(var.ingress_ports, count.index)
}
# Creates multiple inbound rules based on ingress_ports and ingress_cidr variables
# Each rule allows TCP traffic to specific ports from specific IP ranges
# Example: If ingress_ports = [22, 80] and ingress_cidr = ["10.0.0.0/16", "0.0.0.0/0"], it creates rules for SSH (22) and HTTP (80)
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
# Allows all outbound traffic to any destination (0.0.0.0/0)
# ip_protocol = "-1" means all protocols (TCP, UDP, ICMP, etc.)

resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.app_pub_subnet[0].id
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data              = filebase64("${path.module}/userdata.sh")
  
  # Explicitly enable public IP (redundant with map_public_ip_on_launch but good practice)
  associate_public_ip_address = true
  
  tags = {
    Name        = "${var.env}-instance"
    Environment = var.env
  }
}

# Launches an EC2 instance with:
# Latest Amazon Linux 2023 AMI (from the data source)
# Instance type from variable (like "t2.micro")
# Placed in the first public subnet (app_pub_subnet[0])
# Attached to our security group
# Executes startup scripts from userdata.sh (base64 encoded)
# Automatically assigns a public IP address
# Tagged with environment name (like "dev-instance")