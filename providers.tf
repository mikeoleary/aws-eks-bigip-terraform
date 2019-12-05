#
# Provider Configuration
#

provider "aws" {
  region  = "us-west-2"
  version = ">= 2.38.0"
}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

# Not required: currently used in conjuction with using
# icanhazip.com to determine local workstation external IP
# to open EC2 Security Group access to the Kubernetes cluster.
# See workstation-external-ip.tf for additional information.
provider "http" {}

data "aws_eks_cluster" "demo" {
  name = "${aws_eks_cluster.demo.id}"
}

data "aws_eks_cluster_auth" "demo" {
  name = "${aws_eks_cluster.demo.id}"
}

provider "kubernetes" {
  host = "${data.aws_eks_cluster.demo.endpoint}"
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.demo.certificate_authority.0.data)}"
  token = "${data.aws_eks_cluster_auth.demo.token}"
  load_config_file = false
}

provider "helm" {
  install_tiller  = true
  namespace = "${kubernetes_service_account.tiller.metadata[0].namespace}"
  service_account = "${kubernetes_service_account.tiller.metadata[0].name}"

  kubernetes {
    host = "${data.aws_eks_cluster.demo.endpoint}"
    cluster_ca_certificate = "${base64decode(aws_eks_cluster.demo.certificate_authority.0.data)}"
    token = "${data.aws_eks_cluster_auth.demo.token}"
    load_config_file = false
  }
}


