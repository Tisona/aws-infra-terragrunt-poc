locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  repository_name = local.env_vars.locals.ecr_repository_name
  aws_region = local.region_vars.locals.aws_region
}

include {
  path = "../../../../../modules/ssm/ssm.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "ecr" {
  config_path = "../../ecr"
}

dependency "eks-eu-central-1" {
  config_path = "../../../../eu-central-1/prod/eks"
}

dependency "eks-us-east-2" {
  config_path = "../../../../us-east-2/prod/eks"
}

inputs = {
  parameter_prefix = "/deploy/"
  
  parameters = {
    ecr_repository = {
      name  = "ecr_repository"
      value = local.repository_name
      type  = "String"
    },
    primary_region = {
      name  = "primary/region"
      value = "eu-central-1"
      type  = "String"
    },
    primary_kubernetes_cluster = {
      name  = "primary/kubernetes_cluster"
      value = dependency.eks-eu-central-1.outputs.cluster_name
      type  = "String"
    },
    secondary_region = {
      name  = "secondary/region"
      value = "us-east-2"
      type  = "String"
    },
    secondary_kubernetes_cluster = {
      name  = "secondary/kubernetes_cluster"
      value = dependency.eks-us-east-2.outputs.cluster_name
      type  = "String"
    }
  }
}
