terraform {
  backend "s3" {
    bucket  = "terraform-session-backend-bucket-cuneyt"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    workspace_key_prefix = "workspaces"
  }
}