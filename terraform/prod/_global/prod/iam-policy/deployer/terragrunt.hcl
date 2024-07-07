locals {
  name_prefix = "poc-project-deployer-"
  description = "EKS deployer policy"
}

include {
  path = "../../../../../modules/iam-policy/iam.hcl"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  name_prefix = local.name_prefix
  path        = "/"
  description = local.description

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:DescribeCluster"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}
