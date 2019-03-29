resource "aws_route53_zone" "private" {
  name = "${var.private_zone}"

  vpc {
    vpc_id = "${module.vpc.vpc_id}"
  }
}
