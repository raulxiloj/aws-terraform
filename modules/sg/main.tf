resource "aws_security_group" "web_server" {
    name = "Web"
    description = "web"
    vpc_id      = var.vpc_id
    
    ingress {
        description      = "ssh"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [var.cidr_block]
    }

    ingress {
        description      = "http"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = [var.cidr_block]
    }
    
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    
    tags = {
        Name = "rx-sg"
    }
}