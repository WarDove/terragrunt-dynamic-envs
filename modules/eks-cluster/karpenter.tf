module "karpenter" {
  count   = var.enable_karpenter ? 1 : 0
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.23.0"

  cluster_name                  = module.eks.cluster_name
  irsa_oidc_provider_arn        = module.eks.oidc_provider_arn
  node_iam_role_name            = var.node_role_name
  node_iam_role_use_name_prefix = false
  create_access_entry           = true
  create_instance_profile       = true
  enable_irsa                   = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}