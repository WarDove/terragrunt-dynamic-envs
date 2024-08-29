module "karpenter" {
  count   = var.enable_karpenter ? 1 : 0
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.23.0"

  cluster_name                  = var.cluster_name
  irsa_oidc_provider_arn        = var.oidc_provider_arn
  node_iam_role_name            = var.node_role_name
  node_iam_role_use_name_prefix = false
  create_access_entry           = true
  create_instance_profile       = true
  enable_irsa                   = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "helm_release" "karpenter_crd" {
  count            = var.enable_karpenter ? 1 : 0
  namespace        = "karpenter"
  create_namespace = true
  name             = "karpenter-crd"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter-crd"
  version          = var.karpenter_version
  wait             = true
}

resource "helm_release" "karpenter" {
  depends_on = [
    helm_release.karpenter_crd
  ]

  count            = var.enable_karpenter ? 1 : 0
  namespace        = "karpenter"
  create_namespace = false

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter[0].iam_role_arn
  }

  set {
    name  = "settings.interruptionQueue"
    value = module.karpenter[0].queue_name
  }

  set {
    name  = "replicas"
    value = 1
  }
}