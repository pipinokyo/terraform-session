resource "aws_security_group" "alb_sg" {                            # Security Group for ALB
  name        = "${var.tags["Name"]}-alb-sg"                        # Name of the security group
  description = "Security Group for Application Load Balancer"      # Description of the security group
  vpc_id      = var.vpc_id                                          # VPC ID where the security group will be created

  ingress {                                                         # Ingress rules for the security group
    from_port   = 80                                                # Starting port for the rule HTTP port
    to_port     = 80                                                # Ending port for the rule HTTP port
    protocol    = "tcp"                                             # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]                                     # Allows traffic from any IPv4 address
  }

  ingress {                                                         # Ingress rules for the security group
    from_port   = 443                                               # Starting port for the rule HTTPS port
    to_port     = 443                                               # Ending port for the rule HTTPS port 
    protocol    = "tcp"                                             # TCP protocol  
    cidr_blocks = ["0.0.0.0/0"]                                     # Allows traffic from any IPv4 address
  }   

  egress {                                                          # Egress rules for the security group
    from_port   = 0                                                 # All ports
    to_port     = 0                                                 # All ports
    protocol    = "-1"                                              # All protocols
    cidr_blocks = ["0.0.0.0/0"]                                     # Allows traffic to any IPv4 address
  }

  tags = merge(var.tags, { Component = "alb-sg" })                  # Merging tags with the component name
}

resource "aws_security_group" "ec2_sg" {                             # Security Group for EC2 instances
  name        = "${var.tags["Name"]}-ec2-sg"                         # Name of the security group  
  description = "Security Group for EC2 instances"                   # Description of the security group
  vpc_id      = var.vpc_id                                           # VPC ID where the security group will be created

  ingress {                                                          # Ingress rules for the security group
    from_port       = 80                                             # Starting port for the rule HTTP port
    to_port         = 80                                             # Ending port for the rule HTTP port
    protocol        = "tcp"                                          # TCP protocol 
    security_groups = [aws_security_group.alb_sg.id]                 # Allows traffic from the ALB security group
  }

  egress {                                                           # Egress rules for the security group
    from_port   = 0                                                  # All ports
    to_port     = 0                                                  # All ports
    protocol    = "-1"                                               # All protocols  
    cidr_blocks = ["0.0.0.0/0"]                                      # Allows traffic to any IPv4 address 
  }

  tags = merge(var.tags, { Component = "ec2-sg" })                   # Merging tags with the component name
}