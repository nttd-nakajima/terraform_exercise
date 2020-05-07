# ===========================
# Provider
# ===========================
provider "aws" {
  region  = "ap-northeast-1"
  profile = "sandbox"
}

# ===========================
# S3
# ===========================
resource "aws_s3_bucket" "ex_s3_bucket" {
  bucket = "ex-bucket-nakajima"
  acl    = "private"

  tags = {
    Name = "ex-s3-nakajima"
  }
}

resource "aws_s3_bucket_public_access_block" "ex_s3_access_block" {
  bucket                  = aws_s3_bucket.ex_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ex-sg"
  }
}

# ===========================
# Key Pair
# ===========================
resource "aws_key_pair" "ex_kp" {
  key_name   = "ex1-kp"
  public_key = file("~/.ssh/ec2.id_rsa.pub")
}

# ===========================
# EC2
# ===========================
resource "aws_instance" "ex_t2" {
  ami                  = "ami-0f310fced6141e627" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ex_profile.name

  vpc_security_group_ids = [aws_security_group.ex_sg.id]
  subnet_id              = aws_subnet.public_a.id
  key_name               = aws_key_pair.ex_kp.id

  tags = {
    Name = "ex-t2"
  }
}

# ===========================
# IAM Role
# ===========================
resource "aws_iam_role" "ex_iam_role" {
  name               = "ex-iam-role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

  tags = {
    Name = "ex-iam-role"
  }
}

resource "aws_iam_instance_profile" "ex_profile" {
  name = "ex-profile"
  role = aws_iam_role.ex_iam_role.name
}

resource "aws_iam_role_policy" "ex_iam_policy" {
  name = "ex-iam-policy"
  role = aws_iam_role.ex_iam_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:PutObject"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

# ===========================
# Cloud watch
# ===========================
resource "aws_cloudwatch_metric_alarm" "ex_recovery" {
  alarm_name = "ex-recovery"
  namespace = "AWS/EC2"
  evaluation_periods = 2
  period = 60

  alarm_actions = ["arn:aws:automate:ap-northeast-1:ec2:recover"]

  statistic = "Minimum"
  comparison_operator = "GreaterThanThreshold"
  threshold = 0.0
  metric_name = "StatusCheckFailed_System"

  dimensions = {
    InstanceId = aws_instance.ex_t2.id
  }

  depends_on = [aws_instance.ex_t2]
}