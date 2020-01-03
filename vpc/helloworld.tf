
resource "kubernetes_deployment" "f5helloworld-deployment" {
  metadata {
    name = "f5helloworld-deployment"
    labels = {
      app = "f5helloworld"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "f5helloworld"
      }
    }
    template {
      metadata {
        labels = {
          app = "f5helloworld"
        }
      }
      spec {
        container {
          image = "f5devcentral/f5-hello-world"
          name  = "f5helloworld"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
  depends_on = [
    "aws_eks_node_group.demo"
  ]
}

resource "kubernetes_service" "f5helloworld" {
  metadata {
    name = "f5helloworld-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.f5helloworld-deployment.spec.0.template.0.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "NodePort"
  }
  depends_on = [
    "aws_eks_node_group.demo"
  ]
}

