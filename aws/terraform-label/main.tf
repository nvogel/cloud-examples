locals {

  common_tags = {
    "Environment"  = "myenv"
    "Project"      = "myproject"
    "Team"         = "myteam"
    "Criticity"    = "4"
    "BusinessUnit" = "mybu"
    "Support"      = "myemail@domain.tld"
    "Automation"   = "none"
  }

}

variable "region" {
  default = "eu-west-3"
}

module "vpc-label" {
  source     = "../vendor/terraform-terraform-label"
  namespace  = "mynamespace"
  stage      = "${var.region}"
  name       = "myname"
  attributes = ["att1", "att2"]
  tags =  "${local.common_tags}"
}

output "id" {
 value = "${module.vpc-label.id}"
}

output "tags" {
 value = "${module.vpc-label.tags}"
}
