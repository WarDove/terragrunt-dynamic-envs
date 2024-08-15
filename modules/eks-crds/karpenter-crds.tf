resource "kubernetes_manifest" "karpenter_nodepool" {
  provider = kubernetes
  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "NodePool"
    metadata = {
      name = "default"
    }
    spec = {
      disruption = {
        consolidationPolicy = var.env == "production" ? "WhenEmpty" : "WhenUnderutilized"
        expireAfter         = "720h"
      }
      limits = {
        cpu    = "800"
        memory = "800Gi"
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

resource "kubernetes_manifest" "karpenter_ec2nodeclass" {
  provider = kubernetes
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