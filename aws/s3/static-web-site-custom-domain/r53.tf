resource "aws_route53_zone" "main" {
  name = "aws.vgl.re"
}

resource "aws_route53_record" "dev" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "aws.vgl.re"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.main.name_servers.0}",
    "${aws_route53_zone.main.name_servers.1}",
    "${aws_route53_zone.main.name_servers.2}",
    "${aws_route53_zone.main.name_servers.3}",
  ]
}

resource "aws_route53_record" "root" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "website.aws.vgl.re"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.website.website_domain}"
    zone_id                = "${aws_s3_bucket.website.hosted_zone_id}"
    evaluate_target_health = false
  }
}
