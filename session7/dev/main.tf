

module "sg" {
  source = "../../modules/sg"
  name = "dev-instance-sg"
  description = "Security group for dev instance"
  ingress_ports = [22]
  ingress_cidrs = [ "10.0.0.0/32" ]
}

module "ec2" {
  source = "../../modules/ec2"
  env = "dev"
  name = "dev-instance"
  description = "EC2 instance for dev environment"
  instance_type = "t2.micro"
  ami = data.aws_ami.amazon_linux_2023.id # Amazon Linux 2 AMI
  vpc_security_group_ids = [module.sg.aws_security_group_id]
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

module "erkin" {
  source = "github.com/Ekanomics/terraform-session//modules/sg"
  name   = "erkin"
  description = "Security group for erkin instance"
  ingress_ports = [22]
  ingress_cidr = [ "10.0.0.0/32" ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
