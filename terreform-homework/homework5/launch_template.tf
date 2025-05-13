resource "aws_security_group" "lt_sg" { # Begins defining a security group for instances launched by the template
  name        = "${var.env}-lt-sg" # Names the SG with environment prefix and adds description
  description = "Security group for launch template instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id # Associates the SG with your VPC (fetched from remote state)

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Allows inbound HTTP traffic (port 80) ONLY from the ALB's security group
  } # More secure than using CIDR blocks as it restricts access to just the ALB

  egress { # Allows all outbound traffic to anywhere
    from_port   = 0       # 0 means all ports
    to_port     = 0
    protocol    = "-1" # -1 means all protocols (TCP, UDP, ICMP, etc.)
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-lt-sg"
    Environment = var.env
  }
}

resource "aws_launch_template" "app_lt" { # Begins defining the launch template for EC2 instances
  name                   = "${var.env}-app-lt" # Names the template with environment prefix (like "dev-app-lt")
  image_id               = data.aws_ami.amazon_linux_2023.id # Uses the Amazon Linux 2023 AMI we looked up earlier
  instance_type          = var.instance_type # Uses the instance type we defined in variables.tf (like "t2.micro")
  vpc_security_group_ids = [aws_security_group.lt_sg.id] # Applies the security group we just created

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
              )

  tag_specifications { # Automatically tags all launched instances with:
    resource_type = "instance"

    tags = {
      Name        = "${var.env}-app-instance" # Tags instances with environment prefix (like "dev-app-instance")
      Environment = var.env # Also tags instances with environment name (like "dev")
    }
  }

  tags = { # Tags the launch template itself for organization
    Name        = "${var.env}-app-lt"
    Environment = var.env
  }
}