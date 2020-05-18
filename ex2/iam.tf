# ===========================
# IAM Role
# ===========================
resource "aws_iam_role" "assume_role" {
  name               = "ex2-assume-role"
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
    Name = "ex2-assume-role"
  }
}

resource "aws_iam_instance_profile" "web" {
  name = "ex2-web-profile"
  role = aws_iam_role.assume_role.name
}

resource "aws_iam_role_policy" "web" {
  name = "ex2-web-policy"
  role = aws_iam_role.assume_role.id

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