resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  subject {
    kind = "User"
    name = "system:serviceaccount:kube-system:tiller"
  }

  role_ref {
    kind  = "ClusterRole"
    name = "cluster-admin"
    api_group="rbac.authorization.k8s.io"
  }
  depends_on = [
    "aws_eks_node_group.demo"
  ]
} 

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
  depends_on = [
    "aws_eks_node_group.demo"
  ]
}