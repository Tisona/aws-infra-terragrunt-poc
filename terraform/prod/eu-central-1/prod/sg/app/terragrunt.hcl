locals {
  name        = "poc-app-sg"
  description = "Security group for application"

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

  mock_outputs = {
    vpc_id                          = "mock-vpc-id"
    elasticache_subnets_cidr_blocks = "10.10.0.0/16,10.11.0.0/16"
    database_subnets_cidr_blocks    = "10.10.0.0/16,10.11.0.0/16"
  }
}

inputs = {
  name        = "${local.env_name}-${local.name}"
  description = "${local.description}"
  vpc_id      = dependency.vpc.outputs.vpc_id

  egress_with_cidr_blocks = [
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "Redis access for app"
      cidr_blocks = join(",", dependency.vpc.outputs.elasticache_subnets_cidr_blocks)
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Postgres access for app"
      cidr_blocks = join(",", dependency.vpc.outputs.database_subnets_cidr_blocks)
    }
  ]
}
