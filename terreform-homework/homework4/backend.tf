terraform {
  backend "s3" {
    bucket         = "terraform-session-backend-bucket-cuneyt"
    key            = "terraform-homework/homework4/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}