# ACM Certificate with DNS validation
resource "aws_acm_certificate" "app_cert" {   # Starts creating an SSL/TLS certificate named "app_cert"
  domain_name               = var.domain_name # Sets the primary domain name for the certificate (e.g., "machtap.com")
  subject_alternative_names = var.subject_alternative_names # Optional additional domains to include in the same certificate (e.g., "*.machtap.com")
  validation_method         = "DNS"  # Specifies DNS-based validation (alternative is email validation)

  lifecycle {         # Ensures new certificate is created before old one is destroyed (zero downtime)
    create_before_destroy = true
  }

  tags = {         # Tags the certificate with environment info
    Name        = "${var.env}-app-cert"
    Environment = var.env
  }
}

# Route53 DNS validation records
resource "aws_route53_record" "cert_validation" {   # Creates DNS records needed for certificate validation
  for_each = {        # Loops through all domain validation options from ACM
    for dvo in aws_acm_certificate.app_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }                   # Creates a map of records needed for each domain

  allow_overwrite = true   # Allows overwriting existing records (if any)
  name            = each.value.name  # Name (e.g., "dev.machtap.com")
  records         = [each.value.record] # Value (the validation string)
  ttl             = 60  # Time to live (TTL) for the DNS record (60 seconds)
  type            = each.value.type # Record type (usually CNAME)
  zone_id         = data.aws_route53_zone.main.zone_id # Places records in the specified Route53 hosted zone
}

# ACM Certificate validation
resource "aws_acm_certificate_validation" "cert_validation" { # Resource that waits for certificate validation to complete
  certificate_arn         = aws_acm_certificate.app_cert.arn  # References the certificate we created
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn] # Lists all validation DNS records that need to be checked
} 

# Route53 zone data source
data "aws_route53_zone" "main" { # Looks up an existing Route53 hosted zone
  name         = var.domain_name # Finds zone matching our domain name
  private_zone = false # Specifies this is a public (not private) DNS zone
}

# Route53 ALB alias record
resource "aws_route53_record" "app_alias" { # Creates a DNS record pointing to our ALB
  zone_id = data.aws_route53_zone.main.zone_id # Places record in our hosted zone
  name    = var.env == "prod" ? var.domain_name : "${var.env}.${var.domain_name}" # Sets the record name (e.g., "dev.machtap.com" or "machtap.com")
  # If environment is "prod", use the root domain; otherwise, use the environment prefix
  # Example: For "prod", it would be "machtap.com"; for "dev", it would be "dev.machtap.com"
  type    = "A" # Specifies this is an A record (for IPv4 addresses)

  alias { 
    name                   = aws_lb.app_alb.dns_name # Points to our ALB's DNS name
    zone_id                = aws_lb.app_alb.zone_id  # Uses ALB's hosted zone ID
    evaluate_target_health = true # Enables health checking of the ALB target
  }
}