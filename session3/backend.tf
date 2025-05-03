terraform {
  backend "s3" {
    bucket         = "terraform-session-backend-bucket-cuneyt"
    key            = "session3/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}