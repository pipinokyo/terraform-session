resource "aws_instance" "first_ec2" {
  ami           = "ami-0f88e80871fd81e91"
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.simple_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo '<html><body><h1>Session-2 homework is complete!</h1></body></html>' | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name        = "aws-session2-instance"
    Environment = "dev"
  }
}

resource "aws_security_group" "simple_sg" {
  name        = "aws-session2-sg"
  description = "Security group for AWS session 2"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  
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

# Get the hosted zone data
data "aws_route53_zone" "machtap" {
  name         = "machtap.com."
  private_zone = false
}

# Create Route53 A record
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.machtap.zone_id
  name    = "machtap.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.first_ec2.public_ip]
}

output "website_url" {
  value = "http://machtap.com"
}