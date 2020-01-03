#
# Variables Configuration
#

variable "cluster-name" {
  default = "terraform-eks-demo"
  type    = "string"
}

variable "as3_rpm" {
  default = "f5-appsvcs-3.15.0-6.noarch.rpm"
}
variable "as3_rpm_url" {
  default = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.15.0/f5-appsvcs-3.15.0-6.noarch.rpm"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}
variable "vip_address" {
  default = "10.0.200.0"
}