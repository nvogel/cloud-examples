module "etcd_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.6.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["etcd"]
}

data "template_file" "cloud-init-etcd" {
    template =  "${file("${path.module}/data/base_install.tpl")}"
    count    = 3

    vars {
        name = "etcd-${count.index}"
        role = "etcd"
    }
}

resource "aws_security_group" "etcd" {
  name        = "${module.etcd_label.id}"
  description = "Security group for the etcd servers"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    description = "Allow all for etcd"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow communication from master"
    from_port       = 2379
    to_port         = 2379
    protocol        = "tcp"
    security_groups = ["${aws_security_group.masters-kubernetes-security-group.id}"]
  }

  tags = "${module.k8s_label.tags}"
}

resource "aws_instance" "etcd" {
  count                  = 3
  ami                    = "${data.aws_ami.amazon-linux-2.id}"
  instance_type          = "t2.medium"
  vpc_security_group_ids = ["${aws_security_group.etcd.id}",
                            "${aws_security_group.k8s.id}"
                            ]
  subnet_id              = "${module.private_subnets.az_subnet_ids[element(local.azs, count.index)]}"
  key_name               = "${module.ssh_key_pair.key_name}"
  tags                   = {
    Name = "${module.etcd_label.id}-${count.index}"
  }
  user_data              = "${element(data.template_file.cloud-init-etcd.*.rendered, count.index)}"

}

resource "aws_volume_attachment" "ebs_att" {
  count       = 3
  device_name = "/dev/sde"
  volume_id   = "${element(aws_ebs_volume.etcd-data.*.id, count.index)}"
  instance_id = "${element(aws_instance.etcd.*.id,count.index)}"
  force_detach = true
}

resource "aws_ebs_volume" "etcd-data" {
  count = 3
  availability_zone = "${element(local.azs, count.index)}"
  size  = 10
}

resource "aws_route53_record" "etcd-dns" {
  count = 3

  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "etcd-${count.index}.${var.private_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${element(aws_instance.etcd.*.private_dns, count.index)}"]

}
