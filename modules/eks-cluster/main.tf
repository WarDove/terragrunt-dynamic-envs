module "vpc" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.23.0"

  cluster_version                          = "1.30"
  subnet_ids                               = var.subnet_ids
  enable_cluster_creator_admin_permissions = true

  /* access_entries = {
      test = {
        kubernertes_groups = ["system:masters"]
        type               = "STANDARD"
        principal_arn = ""
        user_name = null
      }
    } */

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
          enabled = var.cw_logs_enabled
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