resource "aws_instance" "main" {
  ami                       = var.ami
  instance_type             = var.instance_type
  vpc_security_group_ids    = var.vpc_security_group_ids
  associate_public_ip_address = true  # Explicitly enable public IP

  
  tags = {
    Name        = "${var.env}-instance"
    Environment = var.env  
  }
}

