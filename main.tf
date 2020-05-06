# ===========================
# Provider
# ===========================
provider "aws" {
  region  = "ap-northeast-1"
  profile = "my-account"
}

# ===========================
# VPC
# ===========================
resource "aws_vpc" "ex_vpc" {
  cidr_block           = "10.5.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "ex-vpc"
  }
}

# ===========================
# Subnet
# ===========================
resource "aws_subnet" "public_a" {
  cidr_block        = "10.5.0.0/24"
  availability_zone = "ap-northeast-1a"
  vpc_id            = aws_vpc.ex_vpc.id

  map_public_ip_on_launch = true

  tags = {
    Name = "ex-public-a"
  }
}

# ===========================
# Internet Gateway
# ===========================
resource "aws_internet_gateway" "ex_igw" {
  vpc_id = aws_vpc.ex_vpc.id

  tags = {
    Name = "ex-igw"
  }
}

# ===========================
# Route table
# ===========================
resource "aws_route_table" "ex_rtt" {
  vpc_id = aws_vpc.ex_vpc.id

  tags = {
    Name = "ex-rtt"
  }
}

resource "aws_route" "ex_rt" {
  gateway_id             = aws_internet_gateway.ex_igw.id
  route_table_id         = aws_route_table.ex_rtt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "ex-rtt-asoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.ex_rtt.id
}

# ===========================
# Security Group
# ===========================
resource "aws_security_group" "ex_sg" {
  name   = "EXERCISE_ALLOW_SSH_SG"
  vpc_id = aws_vpc.ex_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["14.101.163.238/32"]
  }

  tags = {
    Name = "ex-sg"
  }
}

# ===========================
# Key Pair
# ===========================
resource "aws_key_pair" "ex_kp" {
  key_name   = "ex-kp"
  public_key = file("~/.ssh/ec2.id_rsa.pub")
}

# ===========================
# EC2
# ===========================
resource "aws_instance" "ex_t2" {
  ami           = "ami-0f310fced6141e627" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ex_sg.id]
  subnet_id              = aws_subnet.public_a.id
  key_name = aws_key_pair.ex_kp.id

  tags = {
    Name = "ex-t2"
  }
}