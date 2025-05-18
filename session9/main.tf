resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  tags = {
    Name        = "aws-session9-instance"
    Environment = var.env
  }
}

variable "env" {        
  description = "Environment name"
  type        = string
  
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


resource "aws_sqs_queue" "main" {   
    name = "aws-session9-sqs"
}
