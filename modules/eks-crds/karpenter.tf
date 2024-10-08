resource "kubernetes_manifest" "karpenter_nodepool" {
  count = var.enable_karpenter ? 1 : 0

  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "NodePool"
    metadata = {
      name = "default"
    }
    spec = {
      disruption = {
        consolidationPolicy = "WhenEmpty"
        consolidateAfter    = "30m"
        expireAfter         = "720h"
      }
      limits = {
        cpu    = "800"
        memory = "1600Gi"
      }
      template = {
        metadata = {
          labels = {
            self-managed-node                            = "true"
            "bottlerocket.aws/updater-interface-version" = "2.0.0" # https://github.com/bottlerocket-os/bottlerocket-update-operator/tree/develop/deploy/charts/bottlerocket-update-operator#bottlerocket-update-operator-helm-chart
          }
        }
        spec = {
          nodeClassRef = {
            apiVersion = "karpenter.k8s.aws/v1beta1"
            kind       = "EC2NodeClass"
            name       = "default"
          }
          requirements = [
            { key = "karpenter.k8s.aws/instance-category", operator = "In", values = var.env == "production" ? ["m"] : ["t", "m"] },
            { key = "karpenter.k8s.aws/instance-family", operator = "In", values = var.env == "production" ? ["m5"] : ["m5", "m5a", "t3", "t3a"] },
            { key = "karpenter.k8s.aws/instance-cpu", operator = "In", values = var.env == "production" ? ["8", "16", "32", "64"] : ["2", "4", "8", "16", "32"] },
            { key = "topology.kubernetes.io/zone", operator = "In", values = local.azs },
            { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] },
            { key = "karpenter.sh/capacity-type", operator = "In", values = var.env == "production" ? ["on-demand"] : ["spot", "on-demand"] },
            { key = "kubernetes.io/os", operator = "In", values = ["linux"] }
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "karpenter_nodepool_gha_runner" {
  count = var.enable_karpenter ? 1 : 0

  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "NodePool"
    metadata = {
      name = "gha-runner"
    }
    spec = {
      disruption = {
        consolidationPolicy = "WhenEmpty"
        consolidateAfter    = "5m"
      }
      limits = {
        cpu    = "800"
        memory = "1600Gi"
      }
      template = {
        metadata = {
          labels = {
            self-managed-node                            = "true"
            "bottlerocket.aws/updater-interface-version" = "2.0.0"
          }
        }
        spec = {
          nodeClassRef = {
            apiVersion = "karpenter.k8s.aws/v1beta1"
            kind       = "EC2NodeClass"
            name       = "default"
          }
          taints = [
            {
              key    = "gha-runner"
              value  = "true"
              effect = "NoSchedule"
            }
          ]
          requirements = [
            { key = "karpenter.k8s.aws/instance-category", operator = "In", values = ["m"] },
            { key = "karpenter.k8s.aws/instance-family", operator = "In", values = ["m5", "m5a"] },
            { key = "karpenter.k8s.aws/instance-cpu", operator = "In", values = ["8", "16"] },
            { key = "topology.kubernetes.io/zone", operator = "In", values = local.azs },
            { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] },
            { key = "karpenter.sh/capacity-type", operator = "In", values = ["spot"] },
            { key = "kubernetes.io/os", operator = "In", values = ["linux"] }
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "karpenter_ec2nodeclass" {
  count = var.enable_karpenter ? 1 : 0

  manifest = {
    apiVersion = "karpenter.k8s.aws/v1beta1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      instanceProfile = var.node_instance_profile_name
      amiFamily       = "Bottlerocket"
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "kubernetes.io/cluster/${var.cluster_name}" = "owned"
          }
        }
      ]
      tags = {
        Name                     = "${var.cluster_name}-node"
        "karpenter.sh/discovery" = var.cluster_name
      }
    }
  }
}