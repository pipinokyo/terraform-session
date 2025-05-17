resource "aws_vpc" "main" {                                                      # Creates a new VPC resource in AWS. main is the name of the resource.
  cidr_block           = var.vpc_cidr                                            # Uses the passed CIDR block for the VPC in the variable.tf file under the terraform-homework/homework7/dev directory.
  enable_dns_support   = true                                                    # Enables DNS support in the VPC. Allows DNS resolution for instances in the VPC.
  enable_dns_hostnames = true                                                    # Required for private DNS.Enables DNS hostnames in the VPC.Assigns DNS hostnames to instances in the VPC.
  tags                 = merge(var.tags, { Component = "network" })              # Adds "network" tag to the VPC for identification.
}

resource "aws_internet_gateway" "igw" {                                          # Creates an Internet Gateway for the VPC.aws_internet_gateway: Allows public internet access.
  vpc_id = aws_vpc.main.id                                                       # Attaches the Internet Gateway to the VPC created above.
  tags   = merge(var.tags, { Component = "network-igw" })                        # Adds "network-igw" tag to the Internet Gateway for identification.  
}

resource "aws_eip" "nat" {                                                        # Allocates an Elastic IP (EIP) named "nat".
  domain = "vpc"                                                                  # Specifies that the Elastic IP is for a VPC.
  tags   = merge(var.tags, { Component = "network-nat-eip" })                     # Adds "network-nat-eip" tag to the Elastic IP for identification.
}

resource "aws_nat_gateway" "nat" {                                                # Creates a NAT Gateway in the public subnet.
  allocation_id = aws_eip.nat.id                                                  # Associates the Elastic IP with the NAT Gateway.
  subnet_id     = aws_subnet.public[0].id                                         # Places the NAT Gateway in the first public subnet.
  tags          = merge(var.tags, { Component = "network-nat-gw" })               # Adds "network-nat-gw" tag to the NAT Gateway for identification.
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_subnet" "public" {                                                       # Creates public subnets in the VPC
  count                   = length(var.public_subnet_cidrs)                            # Creates 3 subnets
  vpc_id                  = aws_vpc.main.id                                            # Associates the subnets with the VPC created above.
  cidr_block              = var.public_subnet_cidrs[count.index]                       # Uses the passed CIDR block for the public subnets in the variable.tf
  availability_zone       = data.aws_availability_zones.available.names[count.index]   # Uses the availability zones from the data source to create subnets in different AZs.
  map_public_ip_on_launch = true                                                       # Enables public IP assignment for instances launched in the subnet.
  tags                    = merge(var.tags, {                                          # Adds "public" tag to the public subnets for identification.
    Name    = "${var.tags["Name"]}-public-${count.index + 1}",                         # Uses the count.index to create unique names for each subnet.   
    Tier    = "public",                                                                # Tags the subnet with "public" to indicate its purpose.
    AZ      = data.aws_availability_zones.available.names[count.index]                 # Tags the subnet with the availability zone it is created in.
  })
}
  # Uses count to create multiple subnets based on the length of the public_subnet_cidrs variable.
  # The count.index is used to access the specific CIDR block for each subnet.
  # The count.index is a zero-based index, so we add 1 to the index for naming.
  # The availability zone is determined by the index of the count.



resource "aws_subnet" "private" {                                                         # Creates private subnets in the VPC
  count             = length(var.private_subnet_cidrs)                                    # Creates one subnet per CIDR in private_subnet_cidrs.Creates 3 subnets
  vpc_id            = aws_vpc.main.id                                                     # Associates the subnets with the VPC created above.
  cidr_block        = var.private_subnet_cidrs[count.index]                               # Assigns CIDRs (e.g., 10.0.3.0/24, 10.0.4.0/24).Uses the passed CIDR block for the private subnets in the variable.tf
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)] # Cycles through AZs if more subnets than AZs (e.g., 3 subnets in 2 AZs).
  tags              = merge(var.tags, {                                                   # Adds "private" tag to the private subnets for identification.
    Name    = "${var.tags["Name"]}-private-${count.index + 1}",                           # Uses the count.index to create unique names for each subnet.
    Tier    = "private",                                                                  # Tags the subnet with "private" to indicate its purpose.
    AZ      = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]  # Tags the subnet with the availability zone it is created in.
  })
}

resource "aws_route_table" "public" {                                                       # Creates a route table for the public subnets.
  vpc_id = aws_vpc.main.id                                                                  # Associates the route table with the VPC created above.
  route {                                                                                   # Defines a route in the route table. Adds a default route (0.0.0.0/0) to the Internet Gateway.
    cidr_block = "0.0.0.0/0"                                                                # Specifies the destination CIDR block for the route (all IPs).
    gateway_id = aws_internet_gateway.igw.id                                                # Specifies the target for the route (the Internet Gateway).
  }
  tags = merge(var.tags, { Component = "network-public-rt" })                               # Adds "network-public-rt" tag to the route table for identification.
}

resource "aws_route_table_association" "public" {                                           # Associates the public route table with the public subnets.
  count          = length(aws_subnet.public)                                                # Creates one association per public subnet.
  subnet_id      = aws_subnet.public[count.index].id                                        # Uses the count.index to access the specific public subnet.	Links each subnet to the route table.
  route_table_id = aws_route_table.public.id                                                # Specifies the route table to associate with the subnet. Uses the public route table.
}

resource "aws_route_table" "private" {                                                      # Creates a route table for the private subnets.
  vpc_id = aws_vpc.main.id                                                                  # Associates the route table with the VPC created above.
  route {                                                                                   # Defines a route in the route table.Routes outbound traffic (0.0.0.0/0) through the NAT Gateway.
    cidr_block     = "0.0.0.0/0"                                                            # Specifies the destination CIDR block for the route (all IPs).
    nat_gateway_id = aws_nat_gateway.nat.id                                                 # Specifies the target for the route (the NAT Gateway).
  }
  tags = merge(var.tags, { Component = "network-private-rt" })                              # Adds "network-private-rt" tag to the route table for identification.
}

resource "aws_route_table_association" "private" {                                          # Associates the private route table with the private subnets.
  count          = length(aws_subnet.private)                                               # Creates one association per private subnet.
  subnet_id      = aws_subnet.private[count.index].id                                       # Uses the count.index to access the specific private subnet.
  route_table_id = aws_route_table.private.id                                               # Specifies the route table to associate with the subnet. Uses the private route table.
}

data "aws_availability_zones" "available" {                                                 # Fetches available AZs in the current region.
  state = "available"                                                                       # Filters the availability zones to only those that are available.
}