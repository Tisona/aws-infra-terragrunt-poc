# Common variables for the region

locals {
  aws_region                    = "us-east-2"
  vpc_private_subnets_range     = ["10.11.1.0/24", "10.11.2.0/24"]
  vpc_intra_subnets_range       = ["10.11.11.0/24", "10.11.12.0/24"]
  vpc_public_subnets_range      = ["10.11.101.0/24", "10.11.102.0/24"]
  vpc_database_subnets_range    = ["10.11.21.0/24", "10.11.22.0/24"]
  vpc_elasticache_subnets_range = ["10.11.31.0/24", "10.11.32.0/24"]
  vpc_azs                       = ["us-east-2a", "us-east-2b"]
  vpc_cidr                      = "10.11.0.0/16"
}