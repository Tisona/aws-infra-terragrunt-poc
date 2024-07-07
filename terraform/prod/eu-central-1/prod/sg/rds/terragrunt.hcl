locals {
  name        = "poc-rds-sg"
  description = "Security group for RDS"

  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name
}

include {
  path = "../../../../../modules/sg/sg.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc_main" {
  config_path = "../../../../eu-central-1/prod/vpc"

  mock_outputs = {
    vpc_id         = "mock-vpc-id"
    vpc_cidr_block = "10.10.0.0/16"
  }
}

dependency "vpc_peer_1" {
  config_path = "../../../../us-east-2/prod/vpc"

  mock_outputs = {
    vpc_id         = "mock-vpc-id"
    vpc_cidr_block = "10.11.0.0/16"
  }
}

inputs = {
  name        = "${local.env_name}-${local.name}"
  description = "${local.description}"
  vpc_id      = dependency.vpc_main.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = dependency.vpc_main.outputs.vpc_cidr_block
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = dependency.vpc_peer_1.outputs.vpc_cidr_block
    }
  ]
}
