# Note : Add the annotation to the main metadata of your Deployment. By default this would be reloader.stakater.com/auto.
# https://github.com/stakater/Reloader for more information
resource "helm_release" "reloader" {
  count      = var.enable_reloader ? 1 : 0
  name       = "reloader"
  namespace  = "kube-system"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  version    = var.reloader_version

  values = [
    yamlencode(
      {
        reloader = {
          namespaceSelector = "reloader=enabled"
        }
      }
    )
  ]
}

