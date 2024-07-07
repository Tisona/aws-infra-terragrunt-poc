locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region = local.region_vars.locals.aws_region
}

include {
  path = "../../../../../modules/ssm/ssm.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../../eks"
}

inputs = {
  parameter_prefix = "/deploy/secondary/"
  
  parameters = {
    region = {
      name  = "region"
      value = local.aws_region
      type  = "String"
    },
    kubernetes_cluster = {
      name  = "kubernetes_cluster"
      value = dependency.eks.outputs.cluster_name
      type  = "String"
    }
  }
}
