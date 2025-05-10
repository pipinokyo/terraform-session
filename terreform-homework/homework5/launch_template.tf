resource "aws_security_group" "lt_sg" {
  name        = "${var.env}-lt-sg"
  description = "Security group for launch template instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

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

  tags = {
    Name        = "${var.env}-lt-sg"
    Environment = var.env
  }
}

resource "aws_launch_template" "app_lt" {
  name                   = "${var.env}-app-lt"
  image_id               = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.lt_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
              )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.env}-app-instance"
      Environment = var.env
    }
  }

  tags = {
    Name        = "${var.env}-app-lt"
    Environment = var.env
  }
}