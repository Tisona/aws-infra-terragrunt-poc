terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=20.5.1"

  after_hook "kubeconfig" {
    commands = ["apply"]
    execute  = ["bash", "-c", "aws eks update-kubeconfig --name ${local.cluster_name} --region ${local.aws_region}"]
  }
}