resource "aws_lb" "app_alb" { # Starts defining an Application Load Balancer resource named "app_alb"
  name               = "${var.env}-app-alb" # Names the load balancer with environment prefix (like "dev-app-alb")
  internal           = false                # Sets the load balancer to be internet-facing (not internal)
  load_balancer_type = "application"   # Specifies this is an Application Load Balancer (works at HTTP level)
  security_groups    = [aws_security_group.alb_sg.id] # Attaches the security group we'll define later
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnet_ids # Places it in public subnets (fetched from remote state)

  enable_deletion_protection = false # Allows the ALB to be deleted (true would protect against accidental deletion)

  tags = {  # Adds tags for identification and organization
    Name        = "${var.env}-app-alb"
    Environment = var.env
  }
}

resource "aws_lb_target_group" "app_tg" { # Starts defining a target group named "app_tg"
  name     = "${var.env}-app-tg"  # Names the target group with environment prefix (like "dev-app-tg")
  port     = 80                   # Listens on port 80 for HTTP traffic
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id # Places it in our VPC (fetched from remote state)

  health_check { # Configures health checks:
    enabled             = true        # Enables health checks to monitor target health
    interval            = 30     # Sets the interval between health checks to 30 seconds
    path                = "/"     # Tests the root path ("/")
    port                = "traffic-port" # Uses the port traffic is sent to for health checks
    protocol            = "HTTP"    # Uses HTTP for health checks
    timeout             = 5    # Waits 5 seconds for response
    healthy_threshold   = 3    # Needs 3 successes to mark healthy
    unhealthy_threshold = 3    # Needs 3 failures to mark unhealthy
    matcher             = "200-399" # Accepts HTTP 200-399 status codes
  }

  tags = {  # Adds identifying tags
    Name        = "${var.env}-app-tg"
    Environment = var.env
  }
}

# resource "aws_lb_listener" "app_listener" {
#   load_balancer_arn = aws_lb.app_alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }

#   tags = {
#     Name        = "${var.env}-app-listener"
#     Environment = var.env
#   }
# }

resource "aws_security_group" "alb_sg" { # Starts security group definition for ALB
  name        = "${var.env}-alb-sg"    # Names it with environment prefix (like "dev-alb-sg")
  description = "Security group for ALB"  # Describes its purpose
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id  # Associates with our VPC (fetched from remote state)
 
  ingress {         # Allows inbound HTTP traffic from anywhere
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {        # Allows inbound HTTPS traffic from anywhere 
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {        # Allows all outbound traffic to anywhere
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-alb-sg"
    Environment = var.env
  }
}

# HTTPS Listener
resource "aws_lb_listener" "app_https_listener" {  #Starts HTTPS listener definition
  load_balancer_arn = aws_lb.app_alb.arn        # Attaches to our ALB
  port              = "443"           # Listens on port 443 for HTTPS traffic
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # Uses a predefined SSL policy for security
  certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn  # Uses the validated ACM certificate ARN for HTTPS

  default_action {    # Forwards traffic to our target group
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = {
    Name        = "${var.env}-app-https-listener"
    Environment = var.env
  }
}

# Redirect HTTP to HTTPS
resource "aws_lb_listener" "app_http_redirect" {   # Starts HTTP listener definition
  load_balancer_arn = aws_lb.app_alb.arn           # Attaches to our ALB
  port              = "80"      # Listens on port 80 for HTTP traffic     
  protocol          = "HTTP"

  default_action {   # Sets up redirect action
    type = "redirect"

    redirect {    # Redirects to HTTPS with permanent (301) redirect
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name        = "${var.env}-app-http-redirect"
    Environment = var.env
  }
}