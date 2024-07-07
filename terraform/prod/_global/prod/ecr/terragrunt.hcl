locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  repository_name = local.env_vars.locals.ecr_repository_name
}

include {
  path = "../../../../modules/ecr/ecr.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  repository_name = "${local.repository_name}"
  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
