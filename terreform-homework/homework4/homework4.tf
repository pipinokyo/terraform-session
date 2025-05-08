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

# create Public Subnets with count and element
# Public subnets are subnets that have a route to the internet through an internet gateway.
# Instances in public subnets can communicate directly with the internet.
resource "aws_subnet" "app_pub_subnet" {
  count                   = length(var.public_subnets_cidrs)
  vpc_id                  = aws_vpc.app_vpc1.id
  cidr_block              = element(var.public_subnets_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true  # This is the critical line
  
  tags = {
    Name = "app-pub-subnet-${count.index + 1}"
  }
}


# Create Private Subnets with count and element
# Private subnets are subnets that do not have a route to the internet through an internet gateway.
# Instances in private subnets cannot communicate directly with the internet.
resource "aws_subnet" "app_priv_subnet" {
  count             = length(var.private_subnets_cidrs)
  vpc_id            = aws_vpc.app_vpc1.id
  cidr_block        = element(var.private_subnets_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "app-priv-subnet-${count.index + 1}"
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
resource "aws_route_table_association" "public_subnet" {
  count          = length(var.public_subnets_cidrs)
  subnet_id      = element(aws_subnet.app_pub_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.app_public_rt1.*.id, count.index)
}


# Associate Private Subnets with Private Route Table
# The private subnets must be associated with the private route table.
# This allows instances in the private subnets to use the route table to route traffic to the NAT gateway.
resource "aws_route_table_association" "private_subnet" {
  count          = length(var.private_subnets_cidrs)
  subnet_id      = element(aws_subnet.app_priv_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.app_private_rt1.*.id, count.index)
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
  subnet_id     = aws_subnet.app_pub_subnet[0].id
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



