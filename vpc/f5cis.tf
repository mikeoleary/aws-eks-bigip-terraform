data "helm_repository" "f5-stable" {
  name = "f5-stable"
  url  = "https://f5networks.github.io/charts/stable"
}

resource "helm_release" "f5cis" {
  name  = "f5cis"
  chart = "f5-stable/f5-bigip-ctlr"

  set {
    name  = "args.bigip_url"
    value = "${aws_instance.f5.private_ip}"  
  }
  set {
    name  = "args.bigip_partition"
    value = "kubernetes"  
  }
    set {
    name  = "args.insecure"
    value = "true"  
  }
  set {
    name  = "bigip_login_secret"
    value = "${kubernetes_secret.f5cis.metadata[0].name}"
  }
  depends_on = [
    "kubernetes_service_account.tiller", "kubernetes_cluster_role_binding.tiller", "aws_instance.f5"
  ]
}

resource "kubernetes_secret" "f5cis" {
  metadata {
    name = "f5cis"
    namespace = "kube-system"
  }

  data = {
    username = "admin"
    password = "${random_password.password.result}"
  }
  #type = "kubernetes.io/service-account-token"
  depends_on = [
    "aws_eks_node_group.demo"
  ]
}
