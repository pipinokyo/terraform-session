resource "aws_instance" "main" {
  ami           = "ami-0f88e80871fd81e91"
  instance_type = var.instance_type
  tags = {
    Name        = "${var.env}-instance"
    Environment = var.env  }
  vpc_security_group_ids = [aws_security_group.main.id]
}

resource "aws_security_group" "main" {
  name        = "aws-session3-sg"
  description = "Security group for AWS session 2"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
