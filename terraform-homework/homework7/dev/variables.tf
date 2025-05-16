variable "env" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "Type of instance to create"
  type        = string
  default     = "t2.micro"
}

variable "domain_name" {
  description = "Domain name for ACM certificate and Route53"
  type        = string
  default     = "machtap.com"
}

variable "subject_alternative_names" {
  description = "List of subject alternative names for ACM certificate"
  type        = list(string)
  default     = ["www.machtap.com"]
}

variable "provider_name" {
  description = "Cloud provider name"
  type        = string
  default     = "aws"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "business_unit" {
  description = "Business unit name"
  type        = string
  default     = "orders"
}

variable "tier" {
  description = "Application tier"
  type        = string
  default     = "backend"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "homework7"
}

variable "team" {
  description = "Team name"
  type        = string
  default     = "DevOps"
}

variable "owner" {
  description = "Owner email"
  type        = string
  default     = "cuneyt.omer@gmail.com"
}

variable "managed_by" {
  description = "Managed by"
  type        = string
  default     = "terraform"
}

variable "zone_id" {
  description = "Route53 zone ID"
  type        = string
  default = "Z05622601YFQSX2KL9NQ"
}