
# ###############################
# API Gateway: List
# ###############################
# locals {
#   s3_origin_id = "cloudfront-s3-${aws_s3_bucket.s3_bucket.bucket}"
# }

# cloudfront
resource "aws_cloudfront_distribution" "s3_website_distribution" {
  origin {
    domain_name = aws_s3_bucket.web_host_bucket.website_endpoint
    origin_id   = aws_s3_bucket.web_host_bucket.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # S3 static hosting only supports HTTP
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["${var.app_subdomain_web}.${var.app_domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.web_host_bucket.id

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

  tags = {
    Name = "cloudfront-s3-${var.app_name}"
  }

}
