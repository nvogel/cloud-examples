# add domain delegation for aws.vgl.re
resource "ovh_domain_zone_record" "test" {
    zone = "vgl.re"
    subdomain = "aws"
    fieldtype = "NS"
    ttl = "60"
    target = "${aws_route53_zone.main.name_servers.0}."
}
