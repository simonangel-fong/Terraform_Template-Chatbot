# ########################################
# Cloudflare
# ########################################

resource "cloudflare_record" "cf_record" {
  zone_id = var.cloudflare_zone_id
  name    = local.app_web_address
  content = aws_cloudfront_distribution.cf_distribution.domain_name
  type    = "CNAME"

  ttl     = 1
  proxied = true
}
