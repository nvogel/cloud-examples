module "admin_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.6.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["admin"]
}

resource "aws_security_group" "admin" {
  name        = "${module.admin_label.id}"
  description = "Security group for the admin server"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Allow ssh from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  tags = "${module.admin_label.tags}"
}

resource "aws_instance" "admin" {
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.admin.id}"]
  subnet_id                   = "${module.private_subnets.az_subnet_ids["eu-west-3a"]}"
  key_name                    = "${module.ssh_key_pair.key_name}"
  tags                        = "${module.admin_label.tags}"
}

resource "aws_route53_record" "admin-dns" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "admin.${var.private_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.admin.private_dns}"]
}
