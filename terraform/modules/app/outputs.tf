output "secret_name" {
  value = kubernetes_secret.app.metadata[0].name
}

output "load_balancer_hostname" {
  value = kubernetes_ingress_v1.app.status.0.load_balancer.0.ingress.0.hostname
}

output "load_balancer_arn" {
  value = data.aws_lb.ingress-nginx.arn
}