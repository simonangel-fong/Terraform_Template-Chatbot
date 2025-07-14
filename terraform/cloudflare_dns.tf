# ########################################
# Cloudflare
# ########################################

resource "cloudflare_record" "cf_api_record" {
  zone_id = var.cloudflare_zone_id
  name    = local.app_api_address
  content = aws_api_gateway_domain_name.api_domain.cloudfront_domain_name
  type    = "CNAME"

  ttl     = 1
  proxied = true
}
