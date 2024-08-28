resource "kubernetes_manifest" "cluster_secret_store_aws_secrets" {
  count = var.enable_es ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "cluster-secret-store-aws-secrets"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                namespace : "external-secrets"
                name = "external-secrets"
              }
            }
          }
        }
      }
      conditions = [
        {
          namespaceSelector = {
            matchLabels = {
              "kubernetes.io/environment" = var.env
            }
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "cluster_secret_store_aws_ssm" {
  count = var.enable_es ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "cluster-secret-store-aws-ssm"
    }
    spec = {
      provider = {
        aws = {
          service = "ParameterStore"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                namespace : "external-secrets"
                name = "external-secrets"
              }
            }
          }
        }
      }
      conditions = [
        {
          namespaceSelector = {
            matchLabels = {
              "kubernetes.io/environment" = var.env
            }
          }
        }
      ]
    }
  }
}