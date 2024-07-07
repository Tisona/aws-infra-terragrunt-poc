locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  project_name = local.account_vars.locals.project_name
}

terraform {
  path = "../../../../modules/kms-key"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  description = "EKS Secret Encryption Key for ${include.locals.full_name}"
  alias       = "${local.project_name}_secret_encryption"
}
