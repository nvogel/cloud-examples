data "aws_availability_zones" "available" {}

locals {
  cidr_block = "10.228.160.0/21"

  # azs        = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  azs = "${slice(data.aws_availability_zones.available.names,0,3)}"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=0.4.0"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  cidr_block = "${local.cidr_block}"

  # required for a private hosted zone
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = "${module.vpc.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

resource "aws_vpc_dhcp_options" "this" {
  domain_name     = "${var.private_zone}"
  domain_name_servers = ["AmazonProvidedDNS"]
}

#split in 2 the vpc cidr bloc
# > cidrsubnet("10.228.160.0/21", 1, 0)
#    10.228.160.0/22
# > cidrsubnet("10.228.160.0/21", 1, 1)
#    10.228.164.0/22
locals {
  public_cidr_block  = "${cidrsubnet(module.vpc.vpc_cidr_block, 1, 0)}"
  private_cidr_block = "${cidrsubnet(module.vpc.vpc_cidr_block, 1, 1)}"
}

# For each az, create a public subnet (/25) and a ngw
module "public_subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=0.2.2"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${var.name}"
  availability_zones  = "${local.azs}"
  vpc_id              = "${module.vpc.vpc_id}"
  cidr_block          = "${local.public_cidr_block}"
  type                = "public"
  igw_id              = "${module.vpc.igw_id}"
  nat_gateway_enabled = "true"
}

# For each az, create a private subnet (/25) and a default route the ngw
module "private_subnets" {
  source             = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=0.2.2"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.name}"
  availability_zones = "${local.azs}"
  vpc_id             = "${module.vpc.vpc_id}"
  cidr_block         = "${local.private_cidr_block}"
  type               = "private"

  # Map of AZ names to NAT Gateway IDs that was created in "public_subnets" module
  az_ngw_ids = "${module.public_subnets.az_ngw_ids}"

  # Need to explicitly provide the count since Terraform currently can't use dynamic count on computed resources from different modules
  # https://github.com/hashicorp/terraform/issues/10857
  # https://github.com/hashicorp/terraform/issues/12125
  # https://github.com/hashicorp/terraform/issues/4149
  az_ngw_count = 3
}
