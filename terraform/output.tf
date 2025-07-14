output "api_gateway_domain" {
  value = aws_api_gateway_domain_name.api_domain.cloudfront_domain_name
}

output "s3_web_domain_name" {
  value = aws_s3_bucket.web_host_bucket.website_endpoint
}
