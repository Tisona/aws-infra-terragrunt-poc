locals {
  name = "poc-project-deployer"
}

include {
  path = "../../../../../modules/iam-user/iam.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "iam-policy-deployer" {
  config_path = "../../iam-policy/deployer"
}

inputs = {
  name          = "${local.name}"
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    dependency.iam-policy-deployer.outputs.arn
  ]
  force_destroy = true
  create_iam_user_login_profile = false

  password_reset_required = false
}
