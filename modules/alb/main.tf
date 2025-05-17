resource "aws_lb" "app_lb" {                                       # This resource creates an Application Load Balancer (ALB) in AWS.
  name               = "${var.short_name}-alb"                     # The name of the ALB is set using the passed variable short_name.
  internal           = false                                       # The ALB is external (public). Makes ALB internet-facing.                
  load_balancer_type = "application"                               # Specifies the type of load balancer.
  security_groups    = [var.alb_security_group_id]                 # The security group for the ALB is set using the passed variable.          
  subnets            = var.public_subnet_ids                       # The ALB is associated with the public subnets passed as a variable. Uses public subnets from the network module.
  idle_timeout       = 60                                          # Sets the idle timeout for the ALB to 60 seconds. Connection timeout (sec)
  enable_deletion_protection = false                               # Disables deletion protection for the ALB. This allows the ALB to be deleted without additional steps.     

  tags = merge(var.tags, { Component = "alb" })                    # This tag is used to identify the component of the ALB that this resource belongs to.
}

resource "aws_lb_target_group" "app_tg" {                          # This resource creates a target group for the ALB.
  name        = "${var.short_name}-tg"                             # The name of the target group is set using the passed variable short_name.# Shortened name (e.g., "homework7-dev-orders-tg")
  port        = 80                                                 # The target group listens on port 80, which is the standard port for HTTP traffic. 
  protocol    = "HTTP"                                             # The protocol for the target group is set to HTTP. Layer 7 protocol
  vpc_id      = var.vpc_id                                         # The target group is associated with the VPC passed as a variable. Uses VPC ID from the network module.
  target_type = "instance"                                         # The target type is set to instance, meaning the target group will route traffic to EC2 instances. 

  health_check {                                                   # This block defines the health check settings for the target group.
    enabled             = true                                     # Enables health checks for the target group.
    interval            = 30                                       # Check every 30 seconds. Sets the interval between health checks to 30 seconds. 
    path                = "/"                                      # The path to check for health status. In this case, it checks the root path ("/").
    port                = "traffic-port"                           # The port to check for health status. Uses the traffic port of the target group.
    protocol            = "HTTP"                                   # The protocol for the health check is set to HTTP.
    timeout             = 5                                        # Sets the timeout for the health check to 5 seconds.
    healthy_threshold   = 3                                        # The number of consecutive successful health checks required to consider the target healthy.
    unhealthy_threshold = 3                                        # The number of consecutive failed health checks required to consider the target unhealthy.
    matcher             = "200-399"                                # The HTTP response codes to consider a successful health check. In this case, it accepts any 2xx or 3xx response.
  }

  tags = merge(var.tags, { Component = "alb-target-group" })       # This tag is used to identify the component of the ALB that this target group belongs to.
}
resource "aws_lb_listener" "https" {                               # This resource creates an HTTPS listener for the ALB.
  # depends_on = [aws_acm_certificate_validation.cert]               # Ensures the SSL certificate is validated before creating listener.The listener depends on the certificate validation resource.
  load_balancer_arn = aws_lb.app_lb.arn                            # References the ARN of the ALB this listener attaches to. The ARN of the ALB is passed as a variable.
  port              = 443                                          # The listener listens on port 443, which is the standard port for HTTPS traffic.
  protocol          = "HTTPS"                                      # The protocol for the listener is set to HTTPS.
  ssl_policy        = "ELBSecurityPolicy-2016-08"                  # Specifies the SSL policy for the listener. This policy defines the ciphers and protocols that are supported by the ALB.
  certificate_arn   = var.acm_certificate_arn                      # Uses ACM certificate for HTTPS.This certificate is used to encrypt traffic between clients and the ALB.The ARN of the SSL certificate to use for the listener is passed as a variable. 

  default_action {                                                 # This block defines the default action for the listener.
    type             = "forward"                                   # The default action is to forward traffic to a target group.         
    target_group_arn = aws_lb_target_group.app_tg.arn              # The target group to forward traffic to is referenced here. The ARN of the target group is passed as a variable.
  }

  tags = merge(var.tags, { Component = "alb-https-listener" })     # This tag is used to identify the component of the ALB that this listener belongs to.
}

resource "aws_lb_listener" "http_redirect" {                       # This resource creates an HTTP listener for the ALB. redirects HTTP traffic to HTTPS.
  load_balancer_arn = aws_lb.app_lb.arn                            # Attaches to ALB. References the ARN of the ALB this listener attaches to.
  port              = 80                                           # The listener listens on port 80, which is the standard port for HTTP traffic.
  protocol          = "HTTP"                                       # The protocol for the listener is set to HTTP.

  default_action {                                                 # This block defines the default action for the listener.
    type = "redirect"                                              # The default action is to redirect traffic.

    redirect {                                                     # This block defines the redirect settings.
      port        = "443"                                          # Redirects to port 443, which is the standard port for HTTPS traffic.
      protocol    = "HTTPS"                                        # Redirects to HTTPS. 
      status_code = "HTTP_301"                                     # The HTTP status code for the redirect is set to 301 (permanent redirect).
    }
  }

  tags = merge(var.tags, { Component = "alb-http-listener" })      # This tag is used to identify the component of the ALB that this listener belongs to.
}