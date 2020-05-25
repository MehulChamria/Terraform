variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "private_key_path" {
    default = "/home/mehul/GitHub/AWSKeyPair-1.pem"
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

variable "securityGroupsIngress" {
    type = map
    default = {
        RDP = {
            name        = "RDP port"
            description = "Allow RDP from anywhere"
            from_port   = 3389
            to_port     = 3389
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        WINRM = {
            name        = "WINRM port"
            description = "Allow WINRM from anywhere"
            from_port   = 5985
            to_port     = 5985
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

variable "securityGroupsEgress" {
    type = map
    default = {
        Internet = {
            name        = "All Port"
            description = "Allow Internet access"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

variable "amiID" {
    default = "ami-05cf35bf39c3c0d6d"
}

variable "instanceType" {
    default = "t2.micro"
}

variable "instanceCount" {
    type = number
    default = 1
}