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

  ingress {
    description     = "Allow connections from salt minions"
    from_port       = 4505
    to_port         = 4506
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}", "${aws_security_group.k8s.id}"]
  }

  tags = "${module.admin_label.tags}"
}

data "template_file" "cloud-init-admin" {
    template =  "${file("${path.module}/data/admin_install.tpl")}"

    vars {
        name = "admin"
        role = "admin"
    }
}

resource "aws_instance" "admin" {
  ami                    = "${data.aws_ami.amazon-linux-2.id}"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.admin.id}",
                            "${aws_security_group.k8s.id}"
                            ]
  subnet_id              = "${module.private_subnets.az_subnet_ids["eu-west-3a"]}"
  key_name               = "${module.ssh_key_pair.key_name}"
  tags                   = "${module.admin_label.tags}"
  user_data              = "${data.template_file.cloud-init-admin.rendered}"
}

resource "aws_route53_record" "admin-dns" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "admin.${var.private_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.admin.private_dns}"]
}
