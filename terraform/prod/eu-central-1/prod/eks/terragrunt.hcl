locals {
  cluster_version = "1.29"

  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  env_name     = local.env_vars.locals.env_name
  aws_region   = local.region_vars.locals.aws_region
  project_name = local.account_vars.locals.project_name
  cluster_name = "${local.project_name}-${local.aws_region}"
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=20.5.1"

  after_hook "kubeconfig" {
    commands = ["apply"]
    execute  = ["bash", "-c", "aws eks update-kubeconfig --name ${local.cluster_name} --region ${local.aws_region}"]
  }
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "iam_user_deployer" {
  config_path = "../../../_global/prod/iam-user/deployer"
}

dependency "sg_elasticache" {
  config_path = "../sg/elasticache"
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
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.this[0].id
}
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.this[0].id
}
EOF
}

inputs = {
  cluster_name                   = local.cluster_name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.intra_subnets

  cluster_additional_security_group_ids = [dependency.sg_elasticache.outputs.security_group_id]

  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    "default" = {
      min_size     = 2
      max_size     = 2
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }

  access_entries = {
    deployer = {
      kubernetes_groups = []
      principal_arn     = dependency.iam_user_deployer.outputs.iam_user_arn

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            namespaces = ["prod"]
            type       = "namespace"
          }
        }
      }
    }
  }

}
