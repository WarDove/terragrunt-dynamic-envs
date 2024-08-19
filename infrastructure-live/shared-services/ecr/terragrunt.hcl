include "root" {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "${get_parent_terragrunt_dir()}/development/eks-resources"
  ]
}
