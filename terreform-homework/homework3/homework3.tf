# Terraform script to create a VPC with public and private subnets, route tables, and NAT gateway
resource "aws_vpc" "app_vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "app-vpc1"
  }
}

# create Internet Gateway
# The Internet Gateway allows communication between instances in your VPC and the internet.
# It is a horizontally scaled, redundant, and highly available VPC component that allows communication between instances in your VPC and the internet.
resource "aws_internet_gateway" "app_igw1" {
  vpc_id = aws_vpc.app_vpc1.id
  tags = {
    Name = "app-igw1"
  }
}

# create Public Subnets
# Public subnets are subnets that have a route to the internet through an internet gateway.
# Instances in public subnets can communicate directly with the internet.
resource "aws_subnet" "app_pub_subnet_1a" {
  vpc_id            = aws_vpc.app_vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "app-pub-subnet-1a"
  }
}

resource "aws_subnet" "app_pub_subnet_2b" {
  vpc_id            = aws_vpc.app_vpc1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "app-pub-subnet-2b"
  }
}

resource "aws_subnet" "app_pub_subnet_3c" {
  vpc_id            = aws_vpc.app_vpc1.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "app-pub-subnet-3c"
  }
}

# Create Private Subnets
# Private subnets are subnets that do not have a route to the internet through an internet gateway.
# Instances in private subnets cannot communicate directly with the internet.
resource "aws_subnet" "app_priv_subnet_1a" {
  vpc_id            = aws_vpc.app_vpc1.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "app-priv-subnet-1a"
  }
}

resource "aws_subnet" "app_priv_subnet_2b" {
  vpc_id            = aws_vpc.app_vpc1.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "app-priv-subnet-2b"
  }
}

resource "aws_subnet" "app_priv_subnet_3c" {
  vpc_id            = aws_vpc.app_vpc1.id
  cidr_block        = "10.0.13.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "app-priv-subnet-3c"
  }
}

# Create Route Tables
# Route tables are used to control the routing of traffic within your VPC.
# Each subnet must be associated with a route table.
# A route table contains a set of rules, called routes, that are used to determine where network traffic is directed.
resource "aws_route_table" "app_public_rt1" {
  vpc_id = aws_vpc.app_vpc1.id
  tags = {
    Name = "app-public-rt1"
  }
}

resource "aws_route_table" "app_private_rt1" {
  vpc_id = aws_vpc.app_vpc1.id
  tags = {
    Name = "app-private-rt1"
  }
}

# Create Public Route to Internet Gateway
# The route table for the public subnets must have a route to the internet gateway.
# This allows instances in the public subnets to communicate with the internet.
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.app_public_rt1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.app_igw1.id
}

# Associate Public Subnets with Public Route Table
# The public subnets must be associated with the public route table.
# This allows instances in the public subnets to use the route table to route traffic to the internet.
resource "aws_route_table_association" "public_subnet_1a" {
  subnet_id      = aws_subnet.app_pub_subnet_1a.id
  route_table_id = aws_route_table.app_public_rt1.id
}

resource "aws_route_table_association" "public_subnet_2b" {
  subnet_id      = aws_subnet.app_pub_subnet_2b.id
  route_table_id = aws_route_table.app_public_rt1.id
}

resource "aws_route_table_association" "public_subnet_3c" {
  subnet_id      = aws_subnet.app_pub_subnet_3c.id
  route_table_id = aws_route_table.app_public_rt1.id
}

# Associate Private Subnets with Private Route Table
# The private subnets must be associated with the private route table.
# This allows instances in the private subnets to use the route table to route traffic to the NAT gateway.
resource "aws_route_table_association" "private_subnet_1a" {
  subnet_id      = aws_subnet.app_priv_subnet_1a.id
  route_table_id = aws_route_table.app_private_rt1.id
}

resource "aws_route_table_association" "private_subnet_2b" {
  subnet_id      = aws_subnet.app_priv_subnet_2b.id
  route_table_id = aws_route_table.app_private_rt1.id
}

resource "aws_route_table_association" "private_subnet_3c" {
  subnet_id      = aws_subnet.app_priv_subnet_3c.id
  route_table_id = aws_route_table.app_private_rt1.id
}

# Allocate Elastic IP for NAT Gateway
# An Elastic IP address is a static, public IPv4 address designed for dynamic cloud computing.
# An Elastic IP address is associated with your AWS account and can be associated with any instance or network interface in your VPC.
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Create NAT Gateway
# A NAT gateway is a managed NAT service that provides network address translation (NAT) for instances in a private subnet.
# A NAT gateway allows instances in a private subnet to initiate outbound traffic to the internet while preventing unsolicited inbound traffic from the internet.
resource "aws_nat_gateway" "app_natgateway1" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.app_pub_subnet_1a.id
  tags = {
    Name = "app-natgateway1"
  }
}

# Create Private Route to NAT Gateway
# The route table for the private subnets must have a route to the NAT gateway.
# This allows instances in the private subnets to communicate with the internet through the NAT gateway.
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.app_private_rt1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.app_natgateway1.id
}


# Security Group for WordPress EC2 instance
resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"
  vpc_id      = aws_vpc.app_vpc1.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this to your IP in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-security-group"
  }
}
