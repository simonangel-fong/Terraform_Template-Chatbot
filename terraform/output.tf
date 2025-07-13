output "api_gateway_domain" {
  value = aws_api_gateway_domain_name.api_domain.cloudfront_domain_name
}