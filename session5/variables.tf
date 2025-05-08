variable "env" {
    description = "Environment"
    type        = string
    default     = "dev"
}
  
variable "provider_name" {
    description = "Provider name"
    type        = string
    default     = "aws"
  
}

variable "region" {
    description = "Region"
    type        = string
    default     = "use1"
  
}

variable "business_unit" {
    description = "Business unit"
    type        = string
    default     = "orders"
}

variable "project" {
    description = "Project"
    type        = string
    default     = "tom"
  
}

variable "tier" {
    description = "Tier"
    type        = string
    default     = "db"      
  
}

variable "team" {
    description = "Team"
    type        = string
    default     = "devops"
  
}

variable "owner" {
    description = "Owner"
    type        = string
    default     = "cuneyt"
  
}

variable "managed_by" {
    description = "Managed by"
    type        = string
    default     = "terraform"
  
}

