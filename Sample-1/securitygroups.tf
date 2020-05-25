resource "aws_security_group" "sgIngressRDP" { 
    name        = "RDP port"
    description = "Allow RDP from anywhere"
    vpc_id      = aws_vpc.vpc-1.id

    ingress {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sgIngressWinRM" { 
    name        = "WinRM port"
    description = "Allow WinRM over HTTP from anywhere"
    vpc_id      = aws_vpc.vpc-1.id

    ingress {
        from_port   = 5985
        to_port     = 5985
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sgIngressWinRMHTTPS" { 
    name        = "WinRM port HTTPS"
    description = "Allow WinRM over HTTPS from anywhere"
    vpc_id      = aws_vpc.vpc-1.id

    ingress {
        from_port   = 5986
        to_port     = 5986
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