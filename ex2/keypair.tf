# ===========================
# Key Pair
# ===========================
resource "aws_key_pair" "keypair" {
  key_name   = "ex2-keypair"
  public_key = file("~/.ssh/ec2.id_rsa.pub")
}
