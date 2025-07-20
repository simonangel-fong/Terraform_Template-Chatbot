
# ###############################
# API Gateway: List
# ###############################

locals {
  s3_origin_id  = "cloudfront-s3-${aws_s3_bucket.web_host_bucket.bucket}"
  api_origin_id = "cloudfront-api-${aws_api_gateway_rest_api.rest_api.id}"
}

# cloudfront
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  # S3 Website Origin
  origin {
    domain_name = aws_s3_bucket.web_host_bucket.website_endpoint
    origin_id   = local.s3_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # S3 host
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # # API Gateway Origin
  # origin {
  #   domain_name = "${aws_api_gateway_rest_api.rest_api.id}.execute-api.${var.aws_region}.amazonaws.com"
  #   origin_id   = local.api_origin_id
  #   origin_path = "/${aws_api_gateway_stage.api_stage.stage_name}"

  #   custom_origin_config {
  #     http_port              = 443
  #     https_port             = 443
  #     origin_protocol_policy = "https-only"
  #     origin_ssl_protocols   = ["TLSv1.2"]
  #   }
  # }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["${var.app_subdomain_web}.${var.app_domain}"]

  # Default cache behavior for S3 static website
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true # Enable query string forwarding

      # Forward important headers for CORS
      headers = [
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
        "Origin",
        "Authorization",
        "Content-Type"
      ]

      cookies {
        forward = "none"
      }
    }
  }


  # # API Gateway Cache behavior
  # ordered_cache_behavior {
  #   path_pattern           = "/${var.aws_apigw_path}/*"
  #   allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #   cached_methods         = ["GET", "HEAD", "OPTIONS"]
  #   target_origin_id       = local.api_origin_id
  #   compress               = true
  #   viewer_protocol_policy = "redirect-to-https"

  #   #   # Disable caching for API responses (dynamic content)
  #   #   cache_policy_id = data.aws_cloudfront_cache_policy.managed_caching_disabled.id

  #   #   # Forward all headers, query strings, and cookies to API Gateway
  #   #   origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_all_viewer.id

  #   #   # Security headers for API responses
  #   #   response_headers_policy_id = data.aws_cloudfront_response_headers_policy.managed_security_headers.id
  # }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = var.aws_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Error pages
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  tags = {
    Name        = "cloudfront-s3-${var.app_name}"
    Environment = "prod"
  }

}
