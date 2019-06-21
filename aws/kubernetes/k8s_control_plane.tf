module "master_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.6.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["master"]
}

module "api_elb_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.6.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["api"]
}

resource "aws_security_group" "masters-kubernetes-security-group" {
  name        = "${module.master_label.id}"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Security group for masters"

  tags = "${module.master_label.tags}"

  ingress {
    description = "Allow all master to master"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow commnucation from the api elb to masters"
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.api-elb-kubernetes-security-group.id}"]
  }
}

/*============ Create elb for kubernetes api  ==============*/
resource "aws_security_group" "api-elb-kubernetes-security-group" {
  name        = "${module.api_elb_label.id}"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Security group for api ELB"

  tags = "${module.api_elb_label.tags}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "k8s-api" {
  name = "${module.api_elb_label.id}"

  listener = {
    instance_port     = 6443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-kubernetes-security-group.id}"]
  subnets         = ["${values(module.private_subnets.az_subnet_ids)}"]
  internal        = true

  health_check = {
    target              = "SSL:6443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  instances = ["${aws_instance.master.*.id}"]

  tags = "${module.api_elb_label.tags}"
}


resource "aws_route53_record" "api-k8s-record" {
  name = "api.${var.private_zone}"
  type = "A"

  alias = {
    name                   = "${aws_elb.k8s-api.dns_name}"
    zone_id                = "${aws_elb.k8s-api.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "${aws_route53_zone.private.zone_id}"
}



# ==================== masters nodes ===============
data "template_file" "cloud-init-master" {
    template =  "${file("${path.module}/data/base_install.tpl")}"
    count    = 3

    vars {
        name = "master-${count.index}"
        role = "master"
    }
}

resource "aws_instance" "master" {
  count                  = 3
  ami                    = "${data.aws_ami.amazon-linux-2.id}"
  instance_type          = "t2.medium"
  vpc_security_group_ids = ["${aws_security_group.masters-kubernetes-security-group.id}",
                            "${aws_security_group.k8s.id}",
                            "${aws_security_group.workers-kubernetes-security-group.id}"
                            ]
  subnet_id              = "${module.private_subnets.az_subnet_ids[element(local.azs, count.index)]}"
  key_name               = "${module.ssh_key_pair.key_name}"
  tags                   = {
    Name = "${module.master_label.id}-${count.index}"
  }
  user_data              = "${element(data.template_file.cloud-init-master.*.rendered, count.index)}"
  source_dest_check = false
}

resource "aws_route53_record" "master-dns" {
  count = 3

  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "master-${count.index}.${var.private_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${element(aws_instance.master.*.private_dns, count.index)}"]

}
