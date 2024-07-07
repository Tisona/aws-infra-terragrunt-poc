locals {
  name        = "poc-zookeeper-sg"
  description = "Security group for zookeeper"

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
      from_port   = 3888
      to_port     = 3888
      protocol    = "tcp"
      description = "Zookeeper access from within main VPC"
      cidr_blocks = dependency.vpc_main.outputs.vpc_cidr_block
    },
    {
      from_port   = 2888
      to_port     = 2888
      protocol    = "tcp"
      description = "Zookeeper access from within main VPC"
      cidr_blocks = dependency.vpc_main.outputs.vpc_cidr_block
    },
    {
      from_port   = 3888
      to_port     = 3888
      protocol    = "tcp"
      description = "Zookeeper access from within peer VPC"
      cidr_blocks = dependency.vpc_peer_1.outputs.vpc_cidr_block
    },
    {
      from_port   = 2888
      to_port     = 2888
      protocol    = "tcp"
      description = "Zookeeper access from within peer VPC"
      cidr_blocks = dependency.vpc_peer_1.outputs.vpc_cidr_block
    }
  ]
}
