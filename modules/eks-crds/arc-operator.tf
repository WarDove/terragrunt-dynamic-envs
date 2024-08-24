# https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller
# https://github.com/actions/actions-runner-controller/blob/master/charts/gha-runner-scale-set/values.yaml
# TODO: test if runs on fargate

# Install the operator and the custom resource definitions (CRDs) in your cluster.
resource "helm_release" "arc" {
  depends_on       = [kubernetes_manifest.karpenter_nodepool_gha_runner]
  count            = var.enable_arc ? 1 : 0
  namespace        = "arc-systems"
  create_namespace = true
  name             = "arc"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set-controller"
  version          = var.arc_version
  wait             = true
}

# Install and configure runner scale set
resource "helm_release" "arc_runner_set" {
  count            = var.enable_arc ? 1 : 0
  depends_on       = [helm_release.arc]
  namespace        = "arc-runners"
  create_namespace = true
  name             = "arc-runner-set"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set"
  version          = var.arc_version
  wait             = true

  set {
    name  = "runnerGroup"
    value = var.arc_runner_group
  }

  set {
    name  = "githubConfigUrl"
    value = var.github_config_url
  }

  set {
    name  = "containerMode.type"
    value = "dind"
  }

  set_sensitive {
    name  = "githubConfigSecret.github_token"
    value = var.arc_pat
  }

  values = [
    yamlencode(
      {
        template = {
          spec = {
            nodeSelector = {
              "karpenter.sh/nodepool" = "gha-runner"
            }
            tolerations = [
              {
                key      = "gha-runner"
                operator = "Equal"
                value    = "true"
                effect   = "NoSchedule"
              }
            ]
          }
        }
      }
    )
  ]
}