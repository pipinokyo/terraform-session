# provider is a Terraform keyword that configures a plugin to interact with a cloud/service
# "aws" specifies we're configuring the AWS provider (maintained by HashiCorp)
provider "aws" {
  region = "us-east-1"
}

# Sets the default AWS region where resources will be created
# us-east-1 is AWS's primary region (Northern Virginia)
# This affects all resources unless they specify their own region