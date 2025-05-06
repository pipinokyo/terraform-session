# Create VPC
resource "aws_vpc" "app_vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "app-vpc1"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "app_igw1" {
  vpc_id = aws_vpc.app_vpc1.id
  tags = {
    Name = "app-igw1"
  }
}

# Create Public Subnets
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

# Create Public Route
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.app_public_rt1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.app_igw1.id
}

# Associate Public Subnets with Public Route Table
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
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Create NAT Gateway
resource "aws_nat_gateway" "app_natgateway1" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.app_pub_subnet_1a.id
  tags = {
    Name = "app-natgateway1"
  }
}

# Create Private Route to NAT Gateway
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.app_private_rt1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.app_natgateway1.id
}