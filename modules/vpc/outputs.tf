output "vpc_id" {
    value = aws_vpc.main.id
    description = "This output contains the VPC id"
}

output "public_subnets" {
    value = aws_subnet.public_subnets
    description = "this output contains a collection of the public subnets"
}

output "private_subnets" {
    value = aws_subnet.private_subnets
    description = "this output contains a collection of the private subnets"
}

output "cidr_block" {
    value = aws_vpc.main.cidr_block
}