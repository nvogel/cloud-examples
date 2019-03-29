module "node_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.6.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["node"]
}

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

resource "aws_security_group" "nodes-kubernetes-security-group" {
  name        = "${module.node_label.id}"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Security group for nodes"

  tags = "${module.node_label.tags}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description              = "Allow all node to node"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    self                     = true
  }

  ingress {
    description              = "Allow master to nodes"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    security_groups          = ["${aws_security_group.masters-kubernetes-security-group.id}"]
  }

}

resource "aws_security_group" "masters-kubernetes-security-group" {
  name        = "${module.master_label.id}"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Security group for masters"

  tags = "${module.master_label.tags}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description              = "Allow all master to master"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    self                     = true
  }

  ingress {
    description              = "Allow api elb to master"
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    security_groups          = ["${aws_security_group.api-elb-kubernetes-security-group.id}"]
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

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elb" "k8s-api" {
  name = "${module.api_elb_label.id}"

  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-kubernetes-security-group.id}"]
  subnets         = ["${values(module.private_subnets.az_subnet_ids)}"]
  internal        = true

  health_check = {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = "${module.api_elb_label.tags}"

}
