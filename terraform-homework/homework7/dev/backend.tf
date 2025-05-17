terraform {
  backend "s3" {
    bucket         = "terraform-session-backend-bucket-cuneyt"                      # S3 bucket to store Terraform state
    key            = "terraform-homework/homework7/dev/terraform.tfstate"           # Path within the bucket for the state file 
    region         = "us-east-1"                                                    # AWS region where the bucket is located
    encrypt        = true                                                           # Enable server-side encryption for the state file 
  }
}

# terraform block: Configures Terraform backend settings.
# backend "s3": Stores state in AWS S3 for team collaboration.
# bucket: Name of the S3 bucket.
# key: Path where the state file is stored.
# region: AWS region of the bucket.
# encrypt: Ensures state file encryption.
# dynamodb_table: Enables state locking to prevent conflicts.