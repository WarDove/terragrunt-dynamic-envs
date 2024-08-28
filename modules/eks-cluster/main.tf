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
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard" # | "strict"
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
        { namespace = "argo-cd" },
        { namespace = "argo-rollouts" }
      ]
    }
  }
}



/*

Strict Enforcement Mode: When you set POD_SECURITY_GROUP_ENFORCING_MODE=strict for vpc-cni, it enforces that all traffic
to and from pods must comply with the security group rules attached to those pods. This means that even if your security
group allows communication between the pods, the CNI plugin will enforce these rules strictly, possibly blocking some
pod-to-pod communication if the security groups or network policies are misconfigured or too restrictive.

In that case you have to explicitly define pod security group and security group policy for the service account to grant
respectively ingress and egress to the pods. Note that this does not affect fargate workloads, as they still get
pod-to-pod communication.


resource "aws_security_group" "test_pod_sg" {
  name   = "test-pod-sg"
  vpc_id = var.eks_vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.albc_backend_sg_id]
  }
}

resource "kubernetes_manifest" "test_sa_sgp" {
  manifest = {
    "apiVersion" = "vpcresources.k8s.aws/v1beta1"
    "kind"       = "SecurityGroupPolicy"
    "metadata" = {
      "name"      = "test-sgp"
      "namespace" = "default"
    }

    "spec" = {
      "serviceAccountSelector" = {
        "matchLabels" = {
          "app" = "test"
        }
      }

      "securityGroups" = {
        "groupIds" = [
          var.eks_sg_id,
          aws_security_group.test_pod_sg.id
        ]
      }
    }
  }
}

*/