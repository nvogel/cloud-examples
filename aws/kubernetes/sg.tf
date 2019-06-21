module "k8s_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.6.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["k8s"]
}

# For etcd, master and worker
resource "aws_security_group" "k8s" {
  name        = "${module.k8s_label.id}"
  description = "Security group for the k8s server"
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

  tags = "${module.k8s_label.tags}"
}
