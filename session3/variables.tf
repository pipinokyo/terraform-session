variable "instance_type" {
  description = "Type of instance to create"
  type        = string
  default     = "t2.micro"
}

variable "env" {
    description = "Environment"
    type        = string
    default     = "qa"
}
  