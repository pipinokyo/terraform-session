variable "name" {
  description = "Environment name"
  type        = string
  default     = "test.sg"
}

variable "description" {
    description = "security group description"
    type        = string
    default     = "test.sg"
}

variable "ingress_ports" {
    description = "Ingress ports"
    type        = list(number)
    default     = [22, 80, 443, 3306]
}

variable "ingress_cidrs" {
    description = "Ingress CIDR blocks"
    type        = list(string)
    default     = ["10.0.0.0/16", "0.0.0.0/0", "10.0.0.0/16"]
  
}


