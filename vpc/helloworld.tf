
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
          "cis.f5.com/as3-pool" = "helloworld_pool"
          "cis.f5.com/as3-tenant" = "app1"
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
    labels = {
      app = kubernetes_deployment.f5helloworld-deployment.spec.0.template.0.metadata[0].labels.app
      "cis.f5.com/as3-pool" = "helloworld_pool"
      "cis.f5.com/as3-tenant" = "app1"
      "cis.f5.com/as3-app" = "helloworld"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.f5helloworld-deployment.spec.0.template.0.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8080
      name = "f5helloworld-service"
    }

    type = "NodePort"
  }
  depends_on = [
    "aws_eks_node_group.demo"
  ]
}

data "template_file" "configmap" {
  template = "${file("../vpc/helloworld.configmap.example")}"
  vars = {
    private_ip = "10.0.0.181"
  }
}

# deploy Kubernetes ConfigMap resource
resource "kubernetes_config_map" "helloworld" {
  metadata {
    name = "f5helloworld"
    namespace= "default"
    labels = {
      f5type= "virtual-server"
      as3= "true"
    }
  }
  data = {
    template = "${data.template_file.configmap.rendered}"
  }
}
