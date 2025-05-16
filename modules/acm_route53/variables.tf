variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "zone_id" {
  description = "Route53 zone ID"
  type        = string
  
}