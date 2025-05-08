// Fetch amazon linux 2023 ami id  

data "aws_ami" "amazon_linux_2023" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.7.*"]
  }

  filter {
    name    = "architecture"
    values  = ["x86_64"]
  }

  filter {
    name    = "virtualization-type"
    values  = ["hvm"]
  }
}

# data "template_file" "user_data" {
#   template = file ("userdata.sh")
#   vars = {
#     environment = var.env
#   }
# }