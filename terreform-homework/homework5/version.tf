terraform { # Begins the Terraform configuration block that contains global settings
  required_version = "~> 1.11.0"  # Specifies the minimum Terraform version required (1.11.x)
  required_providers { # Begins the block that specifies the required providers and their version
    aws = {
      source  = "hashicorp/aws" # Specifies the provider source as "hashicorp/aws
      version = "~> 5.96.0" # Specifies the version of the provider (5.96.x)
    }
  }
}



# Version Pinning:
# Prevents unexpected behavior from version upgrades
# Ensures entire team uses same versions

# Dependency Management:
# Terraform will automatically download the specified AWS provider
# No manual installation needed

# Compatibility Guarantee:
# The configuration will only work with:
# Terraform 1.11.x
# AWS provider 5.96.x

# Security:
# Uses official HashiCorp-maintained provider
# Prevents use of potentially malicious third-party providers