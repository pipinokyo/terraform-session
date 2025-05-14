variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
  
}

variable "instance_type" {
  description = "Type of instance to create"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI

  
}

variable "vpc_security_group_ids" {
  description = "VPC security group IDs"
  type        = list(string)
  default     = ["sg-12345678"] # Replace with your security group ID
  
}