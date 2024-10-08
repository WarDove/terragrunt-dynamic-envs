# ArgoCD
data "aws_route53_zone" "this" {
  count        = var.enable_argo ? 1 : 0
  name         = local.domain_config.domain_name
  private_zone = false
}

module "acm_argo" {
  count   = var.enable_argo ? 1 : 0
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.1.0"

  depends_on = [helm_release.albc]

  domain_name = "argocd.${local.domain_config.domain_name}"
  zone_id     = data.aws_route53_zone.this[0].zone_id

  validation_method   = "DNS"
  wait_for_validation = true
}

resource "helm_release" "argocd" {
  depends_on = [
    helm_release.albc,
    helm_release.external_dns
  ]

  count      = var.enable_argo ? 1 : 0
  name       = "argo-cd"
  namespace  = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argo_cd_version

  create_namespace = true

  set {
    name  = "configs.params.server\\.insecure"
    value = true
  }

  set {
    name  = "configs.cm.timeout\\.reconciliation"
    value = "180s"
  }

  set {
    name  = "notifications.enabled"
    value = false
  }

  set {
    name  = "notifications.secret.create"
    value = false
  }

  set {
    name  = "notifications.cm.create"
    value = false
  }

  dynamic "set" {
    for_each = var.github_webhook ? [1] : []
    content {
      name  = "configs.secret.githubSecret"
      value = var.github_webhook_secret
    }
  }

  values = [
    yamlencode(
      {
        server = {
          ingress = {
            enabled    = true
            controller = "aws" # | generic
            annotations = {
              "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
              "alb.ingress.kubernetes.io/target-type" = "ip"
              "alb.ingress.kubernetes.io/group.name"  = "public"
              "alb.ingress.kubernetes.io/group.order" = "100"
              "alb.ingress.kubernetes.io/actions.ssl-redirect" : "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
              "alb.ingress.kubernetes.io/listen-ports" : "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
              "alb.ingress.kubernetes.io/certificate-arn" : module.acm_argo[0].acm_certificate_arn
              "external-dns.alpha.kubernetes.io/hostname" = "argocd.${local.domain_config.domain_name}"
              "external-dns.alpha.kubernetes.io/ttl"      = "300"
            }
            ingressClassName = "alb"
            hostname         = "argocd.${local.domain_config.domain_name}"
            path             = "/"
            pathType         = "Prefix"
            extraPaths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "ssl-redirect"
                    port = {
                      name = "use-annotation"
                    }
                  }
                }
              }
            ]
          }
        }
        controller = {
          resources = {
            requests = {
              cpu    = "250m"
              memory = "500Mi"
            }
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
          }
        }
      }
    )
  ]
}

resource "kubernetes_secret" "argocd_private_repo_creds_https" {
  count = var.enable_argo ? 1 : 0

  metadata {
    name      = "private-repo-creds-https"
    namespace = helm_release.argocd[0].namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    "type"     = "git"
    "url"      = var.gitops_repo_url
    "username" = "my-token"
    "password" = var.gitops_pat
  }

  type = "Opaque"
}

resource "helm_release" "argo_rollouts" {
  count            = var.enable_argo ? 1 : 0
  name             = "argo-rollouts"
  namespace        = "argo-rollouts"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  version          = var.argo_rollouts_version
  create_namespace = true
}

