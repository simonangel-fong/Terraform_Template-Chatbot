# ###############################
# API Gateway: List
# ###############################

locals {
  s3_origin_id  = "cloudfront-s3-${aws_s3_bucket.web_host_bucket.bucket}"
  api_origin_id = "cloudfront-api-${aws_api_gateway_rest_api.rest_api.id}"
}

# cloudfront
resource "aws_cloudfront_distribution" "cf_distribution" {

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

  # API Gateway Origin
  origin {
    origin_id   = local.api_origin_id
    domain_name = "${aws_api_gateway_rest_api.rest_api.id}.execute-api.${var.aws_region}.amazonaws.com"
    origin_path = ""

    custom_origin_config {
      http_port              = 443
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default cache behavior: S3 website
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "redirect-to-https"

    # Forwards CORS-related headers
    forwarded_values {
      query_string = true # Enable query string forwarding

      # Headers for CORS
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

  # Cache behavior：API Gateway
  ordered_cache_behavior {
    path_pattern           = "/${aws_api_gateway_stage.api_stage.stage_name}/*"
    target_origin_id       = local.api_origin_id
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true

      # header
      headers = [
        "Authorization",
        "Content-Type"
      ]

      cookies {
        forward = "none"
      }
    }

    default_ttl = 0
    max_ttl     = 0
    min_ttl     = 0
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["${var.app_subdomain_web}.${var.app_domain}"]

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
    Name        = "cloudfront-${var.app_name}"
    Environment = "prod"
  }

}
