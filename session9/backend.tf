terraform {
  backend "s3" {
    bucket  = "terraform-session-backend-bucket-cuneyt"
    key     = "session9/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-state-blocking"
  }
}