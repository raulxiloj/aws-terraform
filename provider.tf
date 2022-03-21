provider "aws" {
    region = "us-east-1"
}

module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = "10.0.0.0/24"
}

module "sg" {
    source = "./modules/sg"
    vpc_id = module.vpc.vpc_id
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    owners = ["099720109477"]
}

module "ec2" {
    source = "./modules/ec2"
    instance_ami = data.aws_ami.ubuntu.id
    subnet_id = module.vpc.public_subnets[0].id
    sg_ec2 = [module.sg.sg_server]
}