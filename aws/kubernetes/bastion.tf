module "bastion_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.6.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["bastion"]
}

resource "aws_security_group" "bastion" {
  name        = "${module.bastion_label.id}"
  description = "Security group for the bastion server"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow workstation to ssh on bastion node"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.workstation-external-cidr}"]
  }

  tags = "${module.bastion_label.tags}"
}

data "template_file" "cloud-init-base" {
    template =  "${file("${path.module}/data/base_install.tpl")}"

    vars {
        name = "bastion"
        role = "bastion"
    }
}

resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  subnet_id                   = "${module.public_subnets.az_subnet_ids["eu-west-3a"]}"
  associate_public_ip_address = true
  key_name                    = "${module.ssh_key_pair.key_name}"
  tags                        = "${module.bastion_label.tags}"
  user_data                   = "${data.template_file.cloud-init-base.rendered}"
}

resource "aws_route53_record" "bastion-dns" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "bastion.${var.private_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.bastion.private_dns}"]
}
