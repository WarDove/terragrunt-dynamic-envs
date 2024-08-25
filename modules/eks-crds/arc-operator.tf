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
    name  = "minRunners"
    value = 0
  }

  set {
    name  = "maxRunners"
    value = 50
  }

  set {
    name  = "githubConfigUrl"
    value = var.github_config_url
  }

  /*
    set {
      name  = "containerMode.type"
      value = "dind" # | kubernetes | for customization containerMode should remain empty
    }
  */

  set_sensitive {
    name  = "githubConfigSecret.github_token"
    value = var.arc_pat
  }

  values = [
    yamlencode(
      {
        template = {
          spec = {
            serviceAccountName = "arc-runner-gha-rs-no-permission"
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
            initContainers = [
              {
                name    = "init-dind-externals"
                image   = "ghcr.io/actions/actions-runner:2.319.1" # "ghcr.io/actions/actions-runner:latest"
                command = ["cp", "-r", "-v", "/home/runner/externals/.", "/home/runner/tmpDir/"]
                volumeMounts = [
                  {
                    name      = "dind-externals"
                    mountPath = "/home/runner/tmpDir"
                  }
                ]
              }
            ]
            containers = [
              {
                name    = "runner"
                image   = "ghcr.io/actions/actions-runner:2.319.1" # "ghcr.io/actions/actions-runner:latest"
                command = ["/home/runner/run.sh"]
                env = [
                  {
                    name  = "DOCKER_HOST"
                    value = "unix:///var/run/docker.sock"
                  }
                ]
                resources = {
                  requests = {
                    cpu    = "2"
                    memory = "4Gi"
                  }
                  limits = {
                    cpu    = "4"
                    memory = "8Gi"
                  }
                }
                volumeMounts = [
                  {
                    name      = "work"
                    mountPath = "/home/runner/_work"
                  },
                  {
                    name      = "dind-sock"
                    mountPath = "/var/run"
                  }
                ]
              },
              {
                name  = "dind"
                image = "docker:27.1.2-dind-alpine3.20" #"docker:dind"
                args  = ["dockerd", "--host=unix:///var/run/docker.sock", "--group=$(DOCKER_GROUP_GID)"]
                env = [
                  {
                    name  = "DOCKER_GROUP_GID"
                    value = "123"
                  }
                ]
                resources = {
                  requests = {
                    cpu    = "1"
                    memory = "2Gi"
                  }
                  limits = {
                    cpu    = "2"
                    memory = "4Gi"
                  }
                }
                securityContext = {
                  privileged = true
                }
                volumeMounts = [
                  {
                    name      = "work"
                    mountPath = "/home/runner/_work"
                  },
                  {
                    name      = "dind-sock"
                    mountPath = "/var/run"
                  },
                  {
                    name      = "dind-externals"
                    mountPath = "/home/runner/externals"
                  }
                ]
              }
            ]
            volumes = [
              {
                name     = "work"
                emptyDir = {}
              },
              {
                name     = "dind-sock"
                emptyDir = {}
              },
              {
                name     = "dind-externals"
                emptyDir = {}
              }
            ]
          }
        }
      }
    )
  ]
}

resource "kubernetes_limit_range" "arc_runner_constraints" {
  depends_on = [helm_release.arc_runner_set]

  metadata {
    name      = "arc-runners-limit-range"
    namespace = "arc-runners"
  }

  spec {
    limit {
      type = "Container"

      default_request = {
        cpu    = "500m"
        memory = "1Gi"
      }

      default = {
        cpu    = "1"
        memory = "2Gi"
      }

      max = {
        cpu    = "8"
        memory = "16Gi"
      }

      min = {
        cpu    = "1m"
        memory = "1Mi"
      }
    }
  }
}
