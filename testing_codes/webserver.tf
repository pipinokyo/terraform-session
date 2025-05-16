provider "aws" {
  region = "us-east-1"
}

# Get available subnets in your default VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "machtap-alb-sg"
  description = "Allow HTTP/HTTPS traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for EC2 (no SSH access)
resource "aws_security_group" "web_sg" {
  name        = "machtap-web-sg"
  description = "Allow HTTP only from ALB"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# EC2 Instance (no key pair)
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.available.ids[0] # Use first available subnet
  key_name      = "" # Explicitly no key pair

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<html><body><h1>Hello World from machtap.com!</h1></body></html>" > /var/www/html/index.html
              EOF

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "machtap-web-server"
  }
}

# Load Balancer (using two subnets)
resource "aws_lb" "web" {
  name               = "machtap-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = slice(data.aws_subnets.available.ids, 0, 2) # Use first two available subnets

  enable_deletion_protection = false
}

# Target Group
resource "aws_lb_target_group" "web" {
  name     = "machtap-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path = "/"
  }
}

# Attach instance to target group
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web.id
  port             = 80
}

# HTTPS Listener with your certificate
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:288761734108:certificate/be311af5-fe42-4bb8-9afb-7333163f8a96"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# HTTP Listener that redirects to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Route53 Records
resource "aws_route53_record" "root" {
  zone_id = "Z05622601YFQSX2KL9NQ"
  name    = "machtap.com"
  type    = "A"

  alias {
    name                   = aws_lb.web.dns_name
    zone_id                = aws_lb.web.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = "Z05622601YFQSX2KL9NQ"
  name    = "www.machtap.com"
  type    = "A"

  alias {
    name                   = aws_lb.web.dns_name
    zone_id                = aws_lb.web.zone_id
    evaluate_target_health = false
  }
}

# Outputs
output "website_url" {
  value = "https://machtap.com"
}

output "alb_dns_name" {
  value = aws_lb.web.dns_name
}