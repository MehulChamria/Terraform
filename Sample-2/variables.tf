variable "private_key_path" {
    default = "/home/usr/key.pem"
}

variable "user_data" {
    default = "user_data.sh"
}

variable "key_name" {
    default = "AWSKeyPair-1"
}

variable "region" {
    default = "eu-west-2"
}

data "aws_availability_zones" "azs" {}

variable "vpcCidr" {
    default = "172.16.0.0/16"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-*-amd64-server-*"]
  }
}

variable "instanceType" {
    default = "t2.micro"
}

variable "instanceCount" {
    type = number
    default = 2
}