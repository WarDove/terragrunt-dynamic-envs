include "root" {
  path = find_in_parent_folders()
}

dependency "eks-cluster-dev" {
  config_path = "${get_parent_terragrunt_dir()}/development/eks-cluster"
}

inputs = {
  dev_node_iam_role_arn = dependency.eks-cluster-dev.outputs.node_iam_role_arn
}