provider "aws" {
  region = "ap-northeast-1"
  profile = "sandbox"
}

# VPC
resource "aws_vpc" "ex_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags {
    Name = "tf-k-nakajima-vpc"
  }
}

# Subnet
resource "aws_subnet" "public_a" {
  vpc_id = "${aws_vpc.ex_vpc.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"
  tags {
    Name = "public-a"
  }
}

# Security Group
resource "aws_security_group" "ex_sg" {
  name = "EXERCISE_ALLOW_SSH_SG"
  vpc_id = "${aws_vpc.ex_sg.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["14.101.163.238/24"]
  }
  tags {
    Name = "exercise-allow-ssh"
  }
}

# EC2
resource "aws_instance" "ex_t2" {
  ami = "ami-0f310fced6141e627"  # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"

  vpc_security_group_ids = ["${aws_security_group.ex_sg.id}"]
  subnet_id = "${aws_subnet.public_a.id}"

  tags {
    Name = "tf-k-nakajima-ec2"
  }
}
