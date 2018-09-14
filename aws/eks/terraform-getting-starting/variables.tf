#
# Variables Configuration
#

variable "cluster-name" {
    default = "terraform-eks-demo"
    type    = "string"
}

variable "keypair" {
    default = "nv"
    type    = "string"
}
