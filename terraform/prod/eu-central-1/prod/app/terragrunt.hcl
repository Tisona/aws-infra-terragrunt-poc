locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("app.hcl"))

  rds_db_username       = local.account_vars.locals.rds_db_username
  rds_db_password       = local.account_vars.locals.rds_db_password
  db_dbname             = local.app_vars.locals.app_database
  db_user               = local.app_vars.locals.app_db_user
  db_password           = local.app_vars.locals.app_db_password
  db_ssl                = local.app_vars.locals.app_db_ssl
  db_connections        = local.app_vars.locals.app_db_connections
  db_idle_timeout       = local.app_vars.locals.app_db_idle_timeout
  db_connection_timeout = local.app_vars.locals.app_db_connection_timeout
  application_name      = local.app_vars.locals.app_name
  port                  = local.app_vars.locals.app_port
  log_level             = local.app_vars.locals.app_log_level
}

terraform {
  source = "../../../../modules/app"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "rds" {
  config_path = "../rds"
}

dependency "elasticache" {
  config_path = "../elasticache"
}

dependency "eks" {
  config_path = "../eks"
}

dependency "eks-addons" {
  config_path = "../eks-addons"
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
  name = var.cluster_name
}
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}
EOF
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name

  namespace   = "prod"
  secret_name = "poc-app"
  secret_data = {
    db_user                            = local.db_user
    db_password                        = local.db_password
    db_ssl                             = local.db_ssl
    db_host                            = dependency.rds.outputs.db_instance_address
    db_name                            = dependency.rds.outputs.db_instance_name
    db_port                            = dependency.rds.outputs.db_instance_port
    db_connections                     = local.db_connections
    db_idle_timeout                    = local.db_idle_timeout
    db_connection_timeout              = local.db_connection_timeout
    redis_host                         = dependency.elasticache.outputs.endpoint
    redis_port                         = dependency.elasticache.outputs.port
    application_name                   = local.application_name
    port                               = local.port
    log_level                          = local.log_level
  }
}
