locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  env_name                  = local.env_vars.locals.env_name
  private_subnets_range     = local.region_vars.locals.vpc_private_subnets_range
  intra_subnets_range       = local.region_vars.locals.vpc_intra_subnets_range
  public_subnets_range      = local.region_vars.locals.vpc_public_subnets_range
  database_subnets_range    = local.region_vars.locals.vpc_database_subnets_range
  elasticache_subnets_range = local.region_vars.locals.vpc_elasticache_subnets_range
  azs                       = local.region_vars.locals.vpc_azs
  cidr                      = local.region_vars.locals.vpc_cidr
  aws_region                = local.region_vars.locals.aws_region
  project_name              = local.account_vars.locals.project_name
}

include {
  path = "../../../../modules/vpc/vpc.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  env                 = "${local.env_name}"
  azs                 = "${local.azs}"
  private_subnets     = "${local.private_subnets_range}"
  intra_subnets       = "${local.intra_subnets_range}"
  public_subnets      = "${local.public_subnets_range}"
  database_subnets    = "${local.database_subnets_range}"
  elasticache_subnets = "${local.elasticache_subnets_range}"
  cidr                = "${local.cidr}"
  name                = "${local.project_name}"

  create_database_subnet_group    = true
  create_elasticache_subnet_group = true

  enable_nat_gateway = true 
  single_nat_gateway = true # to reduce costs during testing
}
