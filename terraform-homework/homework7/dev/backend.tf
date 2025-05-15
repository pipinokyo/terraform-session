terraform {
  backend "s3" {
    bucket         = "terraform-session-backend-bucket-cuneyt"
    key            = "terraform-homework/homework7/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}