locals {
  name           = "poc-redis"
  zone_id        = []
  cluster_size   = 1
  instance_type  = "cache.t2.micro"
  engine_version = "7.1"
  family         = "redis7"
  description    = "PoC redis"
}

include {
  path = "../../../../modules/elasticache/elasticache.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "sg_elasticache" {
  config_path = "../sg/elasticache"
}

inputs = {
  name                          = "${local.name}"
  availability_zones            = dependency.vpc.outputs.azs
  zone_id                       = "${local.zone_id}"
  vpc_id                        = dependency.vpc.outputs.vpc_id
  associated_security_group_ids = [dependency.sg_elasticache.outputs.security_group_id]
  subnets                       = dependency.vpc.outputs.elasticache_subnets
  cluster_size                  = "${local.cluster_size}"
  instance_type                 = "${local.instance_type}"
  apply_immediately             = true
  automatic_failover_enabled    = false
  engine_version                = "${local.engine_version}"
  family                        = "${local.family}"
  description                   = "${local.description}"
  replication_group_id          = "poc-redis"
  transit_encryption_enabled    = false

  parameter = [
    {
      name  = "notify-keyspace-events"
      value = "lK"
    }
  ]
}
