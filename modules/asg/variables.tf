variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "ec2_security_group_id" {
  description = "EC2 Security Group ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "target_group_arn" {
  description = "Target Group ARN"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}