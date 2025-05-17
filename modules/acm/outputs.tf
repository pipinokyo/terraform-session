output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = data.aws_acm_certificate.issued.arn
}