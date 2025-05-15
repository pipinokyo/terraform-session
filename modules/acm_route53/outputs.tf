output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = data.aws_acm_certificate.issued.arn
}

output "hosted_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = aws_route53_zone.primary.zone_id
}