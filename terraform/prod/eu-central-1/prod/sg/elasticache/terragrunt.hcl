locals {
  name        = "poc-elasticache-sg"
  description = "Security group for elasticache"

  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name
}

include {
  path = "../../../../../modules/sg/sg.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
  name        = "${local.env_name}-${local.name}"
  description = "${local.description}"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "Redis access from within VPC"
      cidr_blocks = dependency.vpc.outputs.vpc_cidr_block
    }
  ]
}
