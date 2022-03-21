variable instance_ami {
    type = string
    description = "image to use"
}

variable instance_type{
    type = string
    description = "EC2 instance size"
    default = "t2.micro"
}

variable instance_root_device_size {
    type = number
    description = "Root device size in GB"
    default = 8
}

variable subnet_id {
    type = string
    description = "Subnet id that the ec2 will use"
}

variable sg_ec2 {
    type = list(string)
    description = "sg to use on the EC2"
}