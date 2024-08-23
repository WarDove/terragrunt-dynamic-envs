# https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller
# https://github.com/actions/actions-runner-controller/blob/master/charts/gha-runner-scale-set/values.yaml
# TODO: test if runs on fargate

variable "enable_arc" {
  type    = bool
  default = true
}

variable "arc_version" {
  type    = string
  default = "0.9.3"
}

variable "arc_runner_group" {
  default = "default"
}

variable "github_config_url" {
  description = "The URL of your repository, organization, or enterprise. This is the entity that the runners will belong to."
  type        = string
  default     = "https://github.com/allwhere"
}

variable "github_pat" {
  description = "To enable ARC to authenticate to GitHub, generate a personal access token (classic). For more information, see Authenticating to the GitHub API."
  sensitive   = true
  type        = string
}

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
    value = var.github_pat
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