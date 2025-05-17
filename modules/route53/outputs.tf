output "fqdn" {
  description = "FQDN of the Route53 record"
  value       = aws_route53_record.alb_alias.fqdn
}