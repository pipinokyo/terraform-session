variable "instance_type" {
  description = "Type of instance to create"
  type        = string
  default     = "t2.micro"
}

variable "env" {
    description = "Environment"
    type        = string
    default     = "dev"
}

variable "ingress_ports" {
    description = "Ingress ports"
    type        = list(number)
    default     = [22, 80, 443, 3306, 36]
}

variable "ingress_cidrs" {
    description = "Ingress CIDR blocks"
    type        = list(string)
    default     = ["10.0.0.0/16", "0.0.0.0/0", "192.168.0.0/16"]
  
}