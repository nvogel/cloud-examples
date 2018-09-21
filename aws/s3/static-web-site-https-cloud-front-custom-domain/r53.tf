# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/CNAMEs.html

resource "aws_route53_zone" "aws_vgl_re" {
  name = "aws.vgl.re"
}

resource "aws_route53_record" "aws_vgl_re" {
  zone_id = "${aws_route53_zone.aws_vgl_re.zone_id}"
  name    = "aws.vgl.re"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.aws_vgl_re.name_servers.0}",
    "${aws_route53_zone.aws_vgl_re.name_servers.1}",
    "${aws_route53_zone.aws_vgl_re.name_servers.2}",
    "${aws_route53_zone.aws_vgl_re.name_servers.3}",
  ]
}

# Cloud front require that the certificate must be created in us-east-1
resource "aws_acm_certificate" "cert" {
  provider = "aws.virginia"
  domain_name = "static.aws.vgl.re"
  validation_method = "DNS"
}

# https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-validate-dns.html
resource "aws_route53_record" "cert_validation" {
  name = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.aws_vgl_re.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl = 60
}

# This resource represents a successful validation of an ACM certificate in concert with other resources
# This resource implements a part of the validation workflow.
# It does not represent a real-world entity in AWS, therefore changing or deleting this resource on its own has no immediate effect.
resource "aws_acm_certificate_validation" "cert" {
  provider = "aws.virginia"
  certificate_arn = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_route53_record" "root" {
  zone_id = "${aws_route53_zone.aws_vgl_re.zone_id}"
  name    = "static.aws.vgl.re"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.main.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.main.hosted_zone_id}"
    evaluate_target_health = false
  }
}
