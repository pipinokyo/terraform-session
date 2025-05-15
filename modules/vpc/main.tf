resource "aws_vpc" "app_vpc" {  # Changed from app_vpc1 to app_vpc
  cidr_block = var.vpc_cidr_block
  tags = merge(var.common_tags, { Name = "${var.env}-app-vpc" })
}

resource "aws_internet_gateway" "app_igw" {  # Changed from app_igw1 to app_igw
  vpc_id = aws_vpc.app_vpc.id
  tags = merge(var.common_tags, { Name = "${var.env}-app-igw" })
}

resource "aws_subnet" "public" {  # Changed from app_pub_subnet to public
  count                   = length(var.public_subnets_cidrs)
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, { Name = "${var.env}-pub-subnet-${count.index + 1}" })
}

resource "aws_subnet" "private" {  # Changed from app_priv_subnet to private
  count             = length(var.private_subnets_cidrs)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = merge(var.common_tags, { Name = "${var.env}-priv-subnet-${count.index + 1}" })
}

resource "aws_route_table" "public" {  # Changed from app_public_rt1 to public
  vpc_id = aws_vpc.app_vpc.id
  tags = merge(var.common_tags, { Name = "${var.env}-public-rt" })
}

resource "aws_route_table" "private" {  # Changed from app_private_rt1 to private
  vpc_id = aws_vpc.app_vpc.id
  tags = merge(var.common_tags, { Name = "${var.env}-private-rt" })
}

resource "aws_eip" "nat" {  # Changed from nat_eip to nat
  domain = "vpc"
  tags = merge(var.common_tags, { Name = "${var.env}-nat-eip" })
}

resource "aws_nat_gateway" "app_nat" {  # Changed from app_natgateway1 to app_nat
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = merge(var.common_tags, { Name = "${var.env}-app-nat" })
}