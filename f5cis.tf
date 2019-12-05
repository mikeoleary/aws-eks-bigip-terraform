data "helm_repository" "f5-stable" {
  name = "f5-stable"
  url  = "https://f5networks.github.io/charts/stable"
}

resource "helm_release" "f5cis" {
  name  = "f5cis"
  chart = "f5-stable/f5-bigip-ctlr"

  set {
    name  = "args.bigip_url"
    value = "10.0.0.200"
  }

  set {
    name  = "bigip_login_secret"
    value = "${kubernetes_secret.f5cis.metadata[0].name}"
  }

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
}
