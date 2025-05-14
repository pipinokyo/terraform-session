resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  tags = {
    Name        = "${var.env}-instance"
    Name2       = format("%s-instance", var.env)
    Environment = var.env 
  }

  vpc_security_group_ids = [aws_security_group.main.id]
  user_data = templatefile("userdata.sh", { environment = var.env })
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
