
resource "aws_security_group" "main" {
  name        = "security-group"
  description = "allow http and https traffic"

  dynamic "ingress" {
    for_each = var.inbound_ports
    iterator = ports

    content {
      from_port   = ports.value.port
      to_port     = ports.value.port
      protocol    = ports.value.protocol
      cidr_blocks = ports.value.cidr_blocks
    }
  }
} 

variable "inbound_ports" {
  type    = list(object({
    port = number
    protocol = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port = 80
      protocol = "tcp"
      cidr_blocks = ["10.0.0.1/32"]
    },
    {
      port = 443
      protocol = "tcp"
      cidr_blocks = ["10.0.0.10/32"]
    },
    {
      port = 22
      protocol = "tcp"
      cidr_blocks = ["10.0.0.100/32"]
    }
  ]
}