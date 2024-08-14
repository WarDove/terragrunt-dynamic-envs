resource "helm_release" "karpenter_crd" {
  count            = var.create_karpenter ? 1 : 0
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

  count            = var.create_karpenter ? 1 : 0
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
    value = aws_iam_role.karpenter_role[0].arn
  }

  set {
    name  = "settings.interruptionQueue"
    value = aws_sqs_queue.karpenter_interruption_handler_sqs[0].name
  }

  set {
    name  = "replicas"
    value = 1
  }
}