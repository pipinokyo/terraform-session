output "certificate_arn" {                                        # Output the ARN of the ACM certificate
  description = "The ARN of the ACM certificate"                  # Description of the output
  value       = data.aws_acm_certificate.issued.arn               # The ARN of the issued ACM certificate
}