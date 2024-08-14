resource "kubernetes_namespace" "example" {
  metadata {
    annotations = {
      name = "it-works"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "terraform-example-namespace"
  }
}

resource "helm_release" "karpenter_crd" {
  namespace        = "karpenter"
  create_namespace = true
  name             = "karpenter-crd"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter-crd"
  #version          = var.karpenter_helm_version
  wait             = true
}