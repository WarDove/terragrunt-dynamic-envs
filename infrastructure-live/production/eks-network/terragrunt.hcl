include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules/eks-network"
}

inputs = {
  vpc_cidr = "10.0.0.0/16"
}
