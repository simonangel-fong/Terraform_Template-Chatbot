# ###############################
# Output
# ###############################

output "s3_web_domain_name" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}

output "cloudfront_domain" {
  value = "https://${aws_cloudfront_distribution.cf_distribution.domain_name}"
}
