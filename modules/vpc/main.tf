#VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr

    tags = {
        Name = "rx-vpc"
        Owner = var.owner
        Env = terraform.workspace 
    }
}

#Internet Gateway for public subnets
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "rx-ig"
        Environment = terraform.workspace
    }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip1" {
    depends_on = [aws_internet_gateway.ig]
    
    tags = {
        Name = "rx-eip1"
        Environment = terraform.workspace
    }
}

#resource "aws_eip" "nat_eip2" {
#    depends_on = [aws_internet_gateway.ig]
#    
#    tags = {
#        Name = "rx-eip2"
#        Environment = terraform.workspace
#    }
#}
#
#resource "aws_eip" "nat_eip3" {
#    depends_on = [aws_internet_gateway.ig]
#    
#    tags = {
#        Name = "rx-eip3"
#        Environment = terraform.workspace
#    }
#}

# NAT
resource "aws_nat_gateway" "nat1" {
    allocation_id = aws_eip.nat_eip1.id
    subnet_id     = aws_subnet.public_subnets[0].id

    tags = {
        Name = "rx-nat1"
        Environment = terraform.workspace
    }
}

#resource "aws_nat_gateway" "nat2" {
#    allocation_id = aws_eip.nat_eip2.id
#    subnet_id     = aws_subnet.public_subnets[1].id
#
#    tags = {
#        Name = "rx-nat2"
#        Environment = terraform.workspace
#    }
#}
#
#resource "aws_nat_gateway" "nat3" {
#    allocation_id = aws_eip.nat_eip3.id
#    subnet_id     = aws_subnet.public_subnets[2].id
#
#    tags = {
#        Name = "rx-nat3"
#        Environment = terraform.workspace
#    }
#}

#Public subnets
resource "aws_subnet" "public_subnets" {
    count = length(var.list_subnets)

    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 3, (count.index+1))
    availability_zone_id = var.list_subnets[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "rx-public-subnet-${count.index+1}"
        Environment = terraform.workspace
        Subnet = "${var.list_subnets[count.index]}"
    }
} 

#Private subnets
resource "aws_subnet" "private_subnets" {
    count = length(var.list_subnets)

    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 3, (count.index+4))
    availability_zone_id = var.list_subnets[count.index]

    tags = {
        Name = "rx-private-subnet-${count.index+1}"
        Environment = terraform.workspace
        Subnet = "${var.list_subnets[count.index]}"
    }
}

# Route tables
resource "aws_route_table" "public_table" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }

    tags = {
        "Name" = "rx-public-table"
    }
}

resource "aws_route_table" "private_table" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat1.id
    }

    tags = {
        "Name" = "rx-private-table"
    }
}
#If we create a second nat we have to create another route_table to point to that nat

#Associations
resource "aws_route_table_association" "public-associations" {
    count = length(aws_subnet.public_subnets)
    subnet_id = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.public_table.id
}

resource "aws_route_table_association" "private-associations" {
    count = length(aws_subnet.private_subnets)
    subnet_id = aws_subnet.private_subnets[count.index].id
    route_table_id = aws_route_table.private_table.id
}
