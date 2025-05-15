resource "aws_lb" "app_alb" { # Starts defining an Application Load Balancer resource named "app_alb"
  name               = substr(replace(local.name, "rtype", "app-alb"), 0, 32) # Names the load balancer with environment prefix (like "dev-app-alb")
  internal           = false                # Sets the load balancer to be internet-facing (not internal)
  load_balancer_type = "application"   # Specifies this is an Application Load Balancer (works at HTTP level)
  security_groups    = [aws_security_group.alb_sg.id] # Attaches the security group we'll define later
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnet_ids # Places it in public subnets (fetched from remote state)

  enable_deletion_protection = false # Allows the ALB to be deleted (true would protect against accidental deletion)

  tags = merge(
    local.common_tags,
    {Name = replace(local.name, "rtype", "app-alb")} # Adds tags for identification and organization
  ) # Merges common tags with a specific "Name" tag for the ALB
}

resource "aws_lb_target_group" "app_tg" { # Starts defining a target group named "app_tg"
  name     = substr(replace(local.name, "rtype", "app-tg"), 0, 32)  # Names the target group with environment prefix (like "dev-app-tg")
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

  tags = merge(
    local.common_tags,
    {Name = replace(local.name, "rtype", "app-tg")} # Adds tags for identification and organization
  )  # Adds identifying tags
    
  
}

resource "aws_security_group" "alb_sg" { # Starts security group definition for ALB
  name        = replace(local.name, "rtype", "alb-sg")   # Names it with environment prefix (like "dev-alb-sg")
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

  tags = merge(
    local.common_tags,
    {Name = replace(local.name, "rtype", "alb-sg")} # Adds tags for identification and organization
  ) # Merges common tags with a specific "Name" tag for the security group
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

  tags = merge(
    local.common_tags,
    {Name = replace(local.name, "rtype", "app-https-listener")} # Adds tags for identification and organization
  ) # Merges common tags with a specific "Name" tag for the HTTPS listener
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

  tags = merge(
    local.common_tags,
    {Name = replace(local.name, "rtype", "app-http-redirect")} # Adds tags for identification and organization
  ) # Merges common tags with a specific "Name" tag for the HTTP redirect listener
}