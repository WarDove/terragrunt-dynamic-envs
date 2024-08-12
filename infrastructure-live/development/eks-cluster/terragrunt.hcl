include "root" {
  path = find_in_parent_folders()
}

locals {
  cw_logs_enabled = false
}

dependency "eks-network" {
  config_path = "../eks-network"
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/eks/aws?version=20.23.0"
}

inputs = {
  cluster_version = "1.30"
  subnet_ids      = dependency.eks-network.outputs.subnets["private"][*].id

  cluster_addons = {
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        computeType = "fargate"
      })
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_POD_ENI                    = "true"
          ENABLE_PREFIX_DELEGATION          = "true"
          WARM_PREFIX_TARGET                = "1"
          POD_SECURITY_GROUP_ENFORCING_MODE = "strict"
        },
        init = {
          env = {
            DISABLE_TCP_EARLY_DEMUX = "true"
          }
        }
      })
    }
    amazon-cloudwatch-observability = {
      most_recent = true
      configuration_values = jsonencode({
        containerLogs = {
          enabled = local.cw_logs_enabled
        }
      })
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  fargate_profiles = {
    kube-system = {
      selectors = [
        { namespace = "kube-system" }
      ]
    }
  }
}