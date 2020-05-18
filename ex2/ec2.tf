# ===========================
# EC2
# ===========================
resource "aws_instance" "web" {
  count                = 2
  ami                  = "ami-0f310fced6141e627" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.web.name

  vpc_security_group_ids = [aws_security_group.ssh.id, aws_security_group.web.id]
  subnet_id              = element(aws_subnet.public.*.id, count.index % 2)
  key_name               = aws_key_pair.keypair.id

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/ec2.id_rsa")
    }
    inline = [
      "sudo amazon-linux-extras enable nginx1.12 && sudo yum -y install nginx && sudo service nginx start"
    ]
  }

  tags = {
    Name = "${format("ex2-web-%02d", count.index + 1)}"
  }
}

# ===========================
# EIP
# ===========================
# resource "aws_eip" "web" {
#   count    = 2
#   instance = element(aws_instance.web.*.id, count.index)
#   vpc      = true
# }