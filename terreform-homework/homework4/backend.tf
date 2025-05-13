terraform {
  backend "s3" {
    bucket         = "terraform-session-backend-bucket-cuneyt"
    key            = "terraform-homework/homework4/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}


# What Each Part Does:
# backend "s3" - We're telling Terraform to use AWS S3 (Simple Storage Service) as our storage backend

# bucket = "terraform-session-backend-bucket-cuneyt" - This is the name of the specific S3 bucket where we'll store our state file (like a folder in the cloud)

# key = "terraform-homework/homework4/terraform.tfstate" - This is the file path within the bucket where the state will be stored (like a specific drawer in that folder)

# region = "us-east-1" - The AWS region where our S3 bucket lives

# encrypt = true - Ensures our state file is encrypted for security (like putting a lock on that drawer)