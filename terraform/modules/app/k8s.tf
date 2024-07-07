resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "app" {
  metadata {
    name      = var.secret_name
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = var.secret_data

  depends_on = [
    kubernetes_namespace.app,
  ]
}

resource "kubernetes_service" "app" {
  metadata {
    name = "poc-app"
    namespace = var.namespace
    labels = {
      app = "poc-app"
    }
  }
  spec {
    selector = {
      app = "poc-app"
    }
    port {
      port        = 8201
      target_port = 8201
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name = "poc-app"
    namespace = var.namespace
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "poc-app.com"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app.metadata.0.name
              port {
                number = 8201
              }
            }
          }
        }
      }
    }
  }
  wait_for_load_balancer = true
}
