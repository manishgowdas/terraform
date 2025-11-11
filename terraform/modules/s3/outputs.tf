########################################
# S3 Module Outputs
########################################

output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "S3 bucket domain name (useful for access or logging)"
  value       = aws_s3_bucket.this.bucket_domain_name
}
