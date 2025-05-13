resource "aws_autoscaling_group" "app_asg" { # Starts defining an Auto Scaling Group resource named "app_asg"
  name                = "${var.env}-app-asg" # Names the ASG with environment prefix (e.g., "dev-app-asg")
  min_size            = 1 # Minimum number of instances that must always run (even under low load)
  max_size            = 3 # Maximum number of instances allowed (scaling won't exceed this)
  desired_capacity    = 2 # Ideal number of instances to maintain (ASG will aim for this)
  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnet_ids # Places instances in private subnets (fetched from remote state)

  launch_template {
    id      = aws_launch_template.app_lt.id # Specifies which launch template to use for new instances
    version = "$Latest" # Uses the latest version of the template ("$Latest")
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn] # Connects to the target group we created earlier
# New instances automatically register with the load balancer
  tag {
    key                 = "Name" # Applies a "Name" tag to all instances
    value               = "${var.env}-app-asg"
    propagate_at_launch = true # propagate_at_launch means the tag applies to new instances automatically
  }

  tag {
    key                 = "Environment" # Applies an "Environment" tag to all instance
    value               = var.env # Helps identify which environment instances belong to
    propagate_at_launch = true
  }

  lifecycle {  # Ensures new ASG is fully created before old one is destroyed
    create_before_destroy = true
  }
}