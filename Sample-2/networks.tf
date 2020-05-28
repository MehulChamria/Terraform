resource "aws_vpc" "vpc-1" {
  cidr_block       = var.vpcCidr
  instance_tenancy = "default"

  tags = {
    Name = "VPC-1"
  }
}

resource "aws_subnet" "subnets" {
    count                   = length(data.aws_availability_zones.azs.names)
    cidr_block              = cidrsubnet(var.vpcCidr,8,count.index)
    vpc_id                  = aws_vpc.vpc-1.id
    map_public_ip_on_launch = true
    availability_zone       = data.aws_availability_zones.azs.names[count.index]
    tags = {
        Name = "Subnet-${count.index + 1}"
    }
}

resource "aws_internet_gateway" "gw-1" {
  vpc_id = aws_vpc.vpc-1.id

  tags = {
    Name = "IGW-1"
  }
}

resource "aws_default_route_table" "rt-1" {
  default_route_table_id = aws_vpc.vpc-1.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-1.id
  }

  tags = {
    Name = "rt-1"
  }
}