# Common variables for the region

locals {
  aws_region                    = "eu-central-1"
  vpc_private_subnets_range     = ["10.10.1.0/24", "10.10.2.0/24"]
  vpc_intra_subnets_range       = ["10.10.11.0/24", "10.10.12.0/24"]
  vpc_public_subnets_range      = ["10.10.101.0/24", "10.10.102.0/24"]
  vpc_database_subnets_range    = ["10.10.21.0/24", "10.10.22.0/24"]
  vpc_elasticache_subnets_range = ["10.10.31.0/24", "10.10.32.0/24"]
  vpc_azs                       = ["eu-central-1a", "eu-central-1b"]
  vpc_cidr                      = "10.10.0.0/16"
}