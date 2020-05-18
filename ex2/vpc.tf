# ===========================
# VPC
# ===========================
resource "aws_vpc" "vpc" {
  cidr_block           = "10.5.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "ex2-vpc"
  }
}

# ===========================
# Subnet
# ===========================
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = lookup(var.subnets, count.index)
  availability_zone = lookup(var.availability_zones, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "ex2-${lookup(var.availability_zones, count.index)}"
  }
}


# ===========================
# Internet Gateway
# ===========================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "ex2-igw"
  }
}

# ===========================
# Route table
# ===========================
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "ex-route-table"
  }
}

resource "aws_route" "route" {
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "route_table_asoc" {
  count          = 2
  subnet_id      = element(aws_subnet.public.*.id, count.index % 2)
  route_table_id = aws_route_table.route_table.id
}