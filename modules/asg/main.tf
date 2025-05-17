resource "aws_launch_template" "app_lt" {
  name                   = "${var.tags["Name"]}-lt"
  description            = "Launch template for web servers"
  instance_type          = var.instance_type
  image_id               = var.ami_id
  vpc_security_group_ids = [var.ec2_security_group_id]

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

    tags = merge(var.tags, { Component = "asg-instance" })
  }

  tags = merge(var.tags, { Component = "launch-template" })
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.tags["Name"]}-asg"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.tags["Name"]}-asg-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}