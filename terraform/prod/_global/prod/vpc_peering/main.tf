variable "this_vpc_id" {}
variable "peer_vpc_id" {}

provider "aws" {
  alias  = "this"
  region = "eu-central-1"
}

provider "aws" {
  alias  = "peer"
  region = "us-east-2"
}

module "peering" {
  source    = "grem11n/vpc-peering/aws"
  version = "6.0.0"

  providers = {
    aws.this = aws.this
    aws.peer = aws.peer
  }

  this_vpc_id = var.this_vpc_id
  peer_vpc_id = var.peer_vpc_id

  auto_accept_peering = true
}