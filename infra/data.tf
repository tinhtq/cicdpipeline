data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["*ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_caller_identity" "current" {}
data "aws_vpc" "default" {
  default = true
}