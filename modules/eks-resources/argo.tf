# ArgoCD
resource "helm_release" "argocd" {
  depends_on = [
    helm_release.albc,
    helm_release.external_dns
  ]

  count      = var.enable_argocd ? 1 : 0
  name       = "argo"
  namespace  = "argo"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version

  create_namespace = true

  set {
    name  = "configs.params.server\\.insecure"
    value = true
  }

  set {
    name  = "configs.cm.timeout\\.reconciliation"
    value = "180s"
  }

  #   set {
  #     name  = "notifications.enabled"
  #     value = var.notifications
  #   }
  #
  #   set {
  #     name  = "notifications.secret.create"
  #     value = false
  #   }
  #
  #   set {
  #     name  = "notifications.cm.create"
  #     value = false
  #   }

  #   dynamic "set" {
  #     for_each = var.github_webhook ? [1] : []
  #     content {
  #       name  = "configs.secret.githubSecret"
  #       value = var.github_webhook_secret
  #     }
  #   }

  values = [
    yamlencode(
      {
        server = {
          ingress = {
            enabled    = true
            controller = "aws" # | generic
            annotations = {
              #"alb.ingress.kubernetes.io/inbound-cidrs" = join(",", var.access_list_cidr)
              "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
              "alb.ingress.kubernetes.io/target-type" = "ip"
              "alb.ingress.kubernetes.io/group.name"  = "public"
              "alb.ingress.kubernetes.io/group.order" = "100"
              "alb.ingress.kubernetes.io/actions.ssl-redirect" : "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
              "alb.ingress.kubernetes.io/listen-ports" : "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
              "alb.ingress.kubernetes.io/certificate-arn" : var.acm_certificate_arn
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
