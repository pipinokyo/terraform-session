data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.7.*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "lt_sg" {
  name        = "${var.env}-lt-sg"
  description = "Security group for launch template instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.env}-lt-sg" })
}

resource "aws_launch_template" "app_lt" {
  name                   = "${var.env}-app-lt"
  image_id               = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.lt_sg.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    env = var.env
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, { 
      Name = "${var.env}-app-instance" 
    })
  }

  tags = merge(var.common_tags, { Name = "${var.env}-app-lt" })
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.env}-app-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.env}-app-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}