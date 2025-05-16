resource "aws_key_pair" "main" {
    key_name = "terraform-key"
    public_key = file("~/.ssh/id_ed25519.pub")  
}

resource "aws_security_group" "main" {
    name        = "main"
    description = "Security group for Terraform EC2 instance"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"  # Allow all outbound traffic
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "main" {
    ami                       = data.aws_ami.amazon_linux_2023.id  # Amazon Linux 2 AMI
    instance_type             = "t2.micro"
    vpc_security_group_ids    = [aws_security_group.main.id]
    key_name                  = aws_key_pair.main.id
    

    provisioner "file" {
        source      = "/home/cuneyt/terraform/session8/index.html"
        destination = "/tmp/index.html"
    }   
    connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = file("~/.ssh/id_ed25519")
        host        = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [
        "sudo dnf install -y httpd",
        "sudo systemctl start httpd",
        "sudo systemctl enable httpd",
        "sudo cp /tmp/index.html /var/www/html/index.html"
        ]
        connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = file("~/.ssh/id_ed25519")
        host        = self.public_ip
        }
    }

}

resource "null_resource" "main" {
    provisioner "local-exec" {
        command = "echo 'testing local exec' > index.html"
    }

}