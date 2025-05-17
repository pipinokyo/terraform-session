variable "env" {                                                             # Environment variable
  description = "Environment name (dev, staging, prod)"                      # Name of the environment (e.g., dev, staging, prod).
  type        = string                                                       # Type of the variable (string). 
  default     = "dev"                                                        # Default value for the environment variable (dev).
}

variable "instance_type" {                                                    # Instance type variable              
  description = "Type of instance to create"                                  # Description of the variable (type of instance to create). 
  type        = string                                                        # Type of the variable (string).
  default     = "t2.micro"                                                    # Default value for the instance type variable (t2.micro). 
}

variable "domain_name" {                                                       # Domain name variable
  description = "Domain name for ACM certificate and Route53"                  # Description of the variable (domain name for ACM certificate and Route53).
  type        = string                                                         # Type of the variable (string).
  default     = "machtap.com"                                                  # Default value for the domain name variable (machtap.com). 
}

variable "subject_alternative_names" {                                         # Subject alternative names variable                
  description = "List of subject alternative names for ACM certificate"        # Description of the variable (list of subject alternative names for ACM certificate).
  type        = list(string)                                                   # Type of the variable (list of strings).
  default     = ["www.machtap.com"]                                            # Default value for the subject alternative names variable (list of strings).
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
  default     = "Z05622601YFQSX2KL9NQ"
}