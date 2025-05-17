terraform {
  required_version = "~> 1.11.0"                          # Minimum Terraform version
  required_providers {
    aws = {
      source  = "hashicorp/aws"                           # AWS provider source   
      version = "~> 5.96.0"                               # AWS provider version   
    }
  }
}