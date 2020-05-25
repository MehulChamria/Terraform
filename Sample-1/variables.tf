variable "private_key_path" {
    default = "/home/user/AWSKeyPair-1.pem"
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

variable "amiID" {
    default = "ami-05cf35bf39c3c0d6d" #Windows 2016 base ami
}

variable "instanceType" {
    default = "t2.micro"
}

variable "instanceCount" {
    type = number
    default = 1
}