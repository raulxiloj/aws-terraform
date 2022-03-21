resource "aws_instance" "web_server" {
    ami           = var.instance_ami
    instance_type = var.instance_type
    
    subnet_id = var.subnet_id

    root_block_device {
        volume_size = var.instance_root_device_size
        volume_type = "gp3"
    }

    security_groups = var.sg_ec2

    key_name = "rx-key" #This should be a variable, but for a test purpose is fine.

    tags = {
        Name = "web_server"
        Env = terraform.workspace 
    }
}