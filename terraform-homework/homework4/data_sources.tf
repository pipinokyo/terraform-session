// Fetch amazon linux 2023 ami id  

data "aws_ami" "amazon_linux_2023" {
  most_recent      = true
  owners           = ["amazon"]

# What it does:
# Searches for the most recent Amazon Linux 2023 AMI (Amazon Machine Image)
# Only looks at official AMIs owned by Amazon (owners = ["amazon"])
# Applies three filters to find the right image:
  filter {         # Name filter: Looks for AMIs with names matching al2023-ami-2023.7.* (the * is a wildcard)
    name   = "name"
    values = ["al2023-ami-2023.7.*"]
  }

  filter {         # Architecture filter: Only selects 64-bit x86 architecture AMIs
    name    = "architecture"
    values  = ["x86_64"]
  }

  filter {          # Virtualization filter: Only selects HVM (Hardware Virtual Machine) virtualization type AMIs
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

# Reads a file called userdata.sh (which contains startup scripts for EC2 instances)

# Allows you to inject variables into that script (here, an environment variable)

# The var.env would come from a Terraform variable you define elsewhere