resource "aws_instance" "first_ec2" {
  ami           = data.aws_ami.amazon_linux_2023.image_id
  instance_type = "t2.micro"
  tags = {
    Name        = "aws-session9-instance"
    Environment = "dev"
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.7.*"]
  }

  filter {
    name    = "architecture"
    values  = ["x86_64"]
  }

  filter {
    name    = "virtualization-type"
    values  = ["hvm"]
  }
}