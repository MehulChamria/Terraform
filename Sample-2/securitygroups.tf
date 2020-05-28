resource "aws_security_group" "sgIngressSSH" { 
    name        = "SSH port"
    description = "Allow SSH from anywhere"
    vpc_id      = aws_vpc.vpc-1.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sgIngressHTTP" { 
    name        = "HTTP port"
    description = "Allow HTTP from anywhere"
    vpc_id      = aws_vpc.vpc-1.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sgEgressInternet" { 
    name        = "Internet"
    description = "Allow Internet Access"
    vpc_id      = aws_vpc.vpc-1.id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}