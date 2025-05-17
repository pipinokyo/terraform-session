data "aws_acm_certificate" "issued" {                          # Data source to fetch the ACM certificate
  domain   = var.domain_name                                   # var.domain_name: Input variable (e.g., "machtap.com") Domain name for the certificate  
  statuses = ["ISSUED"]                                        # Only fetch certificates that are issued
} 