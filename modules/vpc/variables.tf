variable "vpc_cidr" {
    type = string
    description = "the IP range to use for the VPC"
    default = "10.0.0.0/16"
}

variable "owner" {
    type = string
    default = "Raul"
}

variable "list_subnets" {
    type = list(string)
    description = "list of AZ"
    default = ["use1-az1", "use1-az2", "use1-az3"]
}
