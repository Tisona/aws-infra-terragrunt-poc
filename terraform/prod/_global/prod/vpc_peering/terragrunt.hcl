locals {
  namespace = "btv"

  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name
}

terraform {
  source = "./main.tf"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc1" {
  config_path = "../../../eu-central-1/prod/vpc"

  mock_outputs = {
    vpc_id = "mock-vpc1-id"
  }
}

dependency "vpc2" {
  config_path = "../../../us-east-2/prod/vpc"

  mock_outputs = {
    vpc_id = "mock-vpc2-id"
  }
}

inputs = {
  this_vpc_id = dependency.vpc1.outputs.vpc_id
  peer_vpc_id = dependency.vpc2.outputs.vpc_id
}
