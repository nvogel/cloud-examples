provider "aws" {
  region = "eu-west-3"
}

# Not required: currently used in conjuction with using
# icanhazip.com to determine local workstation external IP
# See workstation-external-ip.tf for additional information.
provider "http" {}
