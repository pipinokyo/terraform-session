variable "domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "List of subject alternative names"
  type        = list(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}