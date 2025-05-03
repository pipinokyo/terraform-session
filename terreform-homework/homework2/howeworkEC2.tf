resource "aws_instance" "first_ec2" {
  ami           = "ami-0f88e80871fd81e91"
  instance_type = "t2.micro"
  
  # Add the security group to the instance
  vpc_security_group_ids = [aws_security_group.simple_sg.id]
  
  # User data script to install and configure HTTPD
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
  
  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  
  # Allow HTTP access (added for the web server)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output the public IP to access the web server
output "instance_public_ip" {
  value = aws_instance.first_ec2.public_ip
}