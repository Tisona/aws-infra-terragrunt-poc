locals {
}

include {
  path = "../../../../modules/eks-addons/eks-addons.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

generate "provider-local" {
  path      = "provider-local.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
data "aws_eks_cluster" "cluster" {
  name = "${dependency.eks.outputs.cluster_name}"
}
data "aws_eks_cluster_auth" "cluster" {
  name = "${dependency.eks.outputs.cluster_name}"
}
EOF
}

inputs = {
  cluster_name      = dependency.eks.outputs.cluster_name
  cluster_endpoint  = dependency.eks.outputs.cluster_endpoint
  cluster_version   = dependency.eks.outputs.cluster_version
  oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn

  # enable_metrics_server = true

  enable_ingress_nginx  = true
  ingress_nginx = {
    name          = "ingress-nginx"
    chart_version = "4.10.0"
    repository    = "https://kubernetes.github.io/ingress-nginx"
    namespace     = "ingress-nginx"
    values        = [templatefile("ingress.yaml", {})]
  }

  enable_kube_prometheus_stack = true
  kube_prometheus_stack        = {
    name          = "kube-prometheus-stack"
    chart_version = "57.0.1"
    repository    = "https://prometheus-community.github.io/helm-charts"
    namespace     = "monitoring"
    values        = [templatefile("prometheus.yaml", {})]
  }
}
