
resource "ovh_domain_zone_record" "test" {
    zone = "vgl.re"
    subdomain = "aws"
    fieldtype = "NS"
    ttl = "60"
    target = "${aws_route53_zone.aws_vgl_re.name_servers.0}."
}
