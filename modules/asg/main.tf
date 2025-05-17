resource "aws_launch_template" "app_lt" {                       # Create a launch template for the ASG.
  name                   = "${var.tags["Name"]}-lt"             # Name of the launch template.  
  description            = "Launch template for web servers"    # Description of the launch template.
  instance_type          = var.instance_type                    # Instance type for the EC2 instances. instance_type = "t2.micro".Ddefined in variables.tf
  image_id               = var.ami_id                           # AMI ID for the EC2 instances.
  vpc_security_group_ids = [var.ec2_security_group_id]          # Security group ID for the EC2 instances.
  # Bootstraps instances with a user data script to install and start Apache web server.
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
              )

  tag_specifications {                                        # Tag specifications for the launch template.
    resource_type = "instance"                                # Resource type for the tags. Here, it's for EC2 instances.

    tags = merge(var.tags, { Component = "asg-instance" })    # Merge the provided tags with a specific tag for the instance.
  }

  tags = merge(var.tags, { Component = "launch-template" })   # Merge the provided tags with a specific tag for the launch template.
}

resource "aws_autoscaling_group" "app_asg" {                   # Create an Auto Scaling Group (ASG) for the application.
  name                = "${var.tags["Name"]}-asg"              # Name of the ASG.
  min_size            = 1                                      # Minimum number of instances in the ASG. 
  max_size            = 3                                      # Maximum number of instances in the ASG.
  desired_capacity    = 2                                      # Desired number of instances in the ASG.
  vpc_zone_identifier = var.private_subnet_ids                 # List of private subnet IDs for the ASG. Uses private subnets for instances.

  launch_template {                                            # Launch template configuration for the ASG. 
    id      = aws_launch_template.app_lt.id                    # ID of the launch template created above.
    version = "$Latest"                                        # Use the latest version of the launch template.
  }

  target_group_arns = [var.target_group_arn]                   # Target group ARN for the ASG. Used for load balancing. Connects to ALB for traffic routing.

  tag {                                                        # Tag for the ASG instances.  
    key                 = "Name"
    value               = "${var.tags["Name"]}-asg-instance"   # Name of the ASG instance.
    propagate_at_launch = true                                 # Applies to all instances. Propagate the tag to the instances launched by the ASG.
  }

  dynamic "tag" {                                              # Dynamic block to create tags for the ASG instances.
    for_each = var.tags                                        # Iterate over the provided tags.
    content {                                                  # Content of the dynamic block.
      key                 = tag.key                            # Tag key (e.g., "Environment") 
      value               = tag.value                          # Tag value (e.g., "dev")
      propagate_at_launch = true                               # Propagate the tag to the instances launched by the ASG.
    }
  }
}