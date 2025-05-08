resource "aws_instance" "first_ec2" {
  ami           = "ami-0f88e80871fd81e91"
  instance_type = "t2.micro"
  tags = {
    Name        = "aws-session2-instance"
    Environment = "dev"
  }
}

resource "aws_instance" "second_ec2" {
  ami           = "ami-0f88e80871fd81e91"
  instance_type = "t2.micro"
  tags = {
    Name        = "aws-session2-instance"
    Environment = "dev"
  }
}

resource "aws_security_group" "simple_sg" {
  name        = "aws-session2-sg"
  description = "Security group for AWS session 2"
  
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

