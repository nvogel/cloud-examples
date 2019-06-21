module "worker_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.6.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["worker"]
}


resource "aws_security_group" "workers-kubernetes-security-group" {
  name        = "${module.worker_label.id}"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Security group for workers"

  tags = "${module.worker_label.tags}"

  ingress {
    description = "Allow all worker to worker"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow master to workers"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.masters-kubernetes-security-group.id}"]
  }
}


# ==================== workers nodes ===============
data "template_file" "cloud-init-worker" {
    template =  "${file("${path.module}/data/base_install.tpl")}"
    count    = 3

    vars {
        name = "worker-${count.index}"
        role = "worker"
    }
}

resource "aws_instance" "worker" {
  count                  = 3
  ami                    = "${data.aws_ami.amazon-linux-2.id}"
  instance_type          = "t2.medium"
  vpc_security_group_ids = ["${aws_security_group.k8s.id}",
                            "${aws_security_group.workers-kubernetes-security-group.id}"
                            ]
  subnet_id              = "${module.private_subnets.az_subnet_ids[element(local.azs, count.index)]}"
  key_name               = "${module.ssh_key_pair.key_name}"
  tags                   = {
    Name = "${module.worker_label.id}-${count.index}"
  }
  user_data              = "${element(data.template_file.cloud-init-worker.*.rendered, count.index)}"
  source_dest_check      = false

}

resource "aws_volume_attachment" "worker_ebs_att" {
  count       = 3
  device_name = "/dev/sde"
  volume_id   = "${element(aws_ebs_volume.worker-data.*.id, count.index)}"
  instance_id = "${element(aws_instance.worker.*.id,count.index)}"
  force_detach = true
}

resource "aws_ebs_volume" "worker-data" {
  count             = 3
  availability_zone = "${element(local.azs, count.index)}"
  size              = 220
}

resource "aws_route53_record" "worker-dns" {
  count = 3

  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "worker-${count.index}.${var.private_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${element(aws_instance.worker.*.private_dns, count.index)}"]

}
