module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.23.0"

  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  subnet_ids                               = var.subnet_ids
  vpc_id                                   = var.vpc_id
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true
  cluster_endpoint_public_access_cidrs     = ["0.0.0.0/0"]

  cluster_addons = {
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        computeType  = "fargate"
        replicaCount = var.env == "production" ? 2 : 1
      })
    },
    kube-proxy = {
      most_recent = true
    },
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
    aws-ebs-csi-driver = {
      most_recent = true
      configuration_values = jsonencode({
        controller = {
          replicaCount = var.env == "production" ? 2 : 1
        }
      })
    }
  }

  fargate_profiles = {
    kube-system = {
      selectors = [
        { namespace = "kube-system" }
      ]
    },
    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    },
    external-secrets = {
      selectors = [
        { namespace = "external-secrets" }
      ]
    },
    external-dns = {
      selectors = [
        { namespace = "external-dns" }
      ]
    },
    argo = {
      selectors = [
        { namespace = "argo" }
      ]
    }
  }
}