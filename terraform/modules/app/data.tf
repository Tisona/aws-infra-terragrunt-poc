data "aws_lb" "ingress-nginx" {
  name = regex(
    "(^[^-]+)",
    kubernetes_ingress_v1.app.status.0.load_balancer.0.ingress.0.hostname
  )[0]
}

