locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  name                  = "poc-prod"
  engine_version        = "16.1"
  family                = "postgres16"
  major_engine_version  = "16"
  allocated_storage     = 10
  max_allocated_storage = 10
  instance_class        = "db.t4g.micro"
  db_name               = "poc-prod"
  username              = local.account_vars.locals.rds_db_username
  password              = local.account_vars.locals.rds_db_password
}

include {
  path = "../../../../modules/rds/rds.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    database_subnet_group_name = "mock-subnet-group-name"
  }
}

dependency "sg_rds" {
  config_path = "../sg/rds"

  mock_outputs = {
    security_group_id = "mock-security-group-id"
  }
}

inputs = {
  identifier = "${local.name}"

  engine               = "postgres"
  engine_version       = "${local.engine_version}"
  family               = "${local.family}" # DB parameter group
  major_engine_version = "${local.major_engine_version}"         # DB option group
  instance_class       = "${local.instance_class}"

  storage_type          = "gp2"
  allocated_storage     = "${local.allocated_storage}"
  max_allocated_storage = "${local.max_allocated_storage}"

  db_name                     = "${local.db_name}"
  username                    = "${local.username}"
  password                    = "${local.password}" # stored in the state
  create_random_password      = false
  manage_master_user_password = false

  port = 5432

  multi_az               = false # to reduce costs during testing
  db_subnet_group_name   = dependency.vpc.outputs.database_subnet_group_name
  vpc_security_group_ids = [dependency.sg_rds.outputs.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "poc-rds-monitoring"
  monitoring_role_use_name_prefix       = true

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
}
