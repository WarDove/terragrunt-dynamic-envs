module "eks-app-permissions" {
  source            = "./modules/eks-app-permissions"
  namespace         = var.namespace
  oidc_provider_arn = var.oidc_provider_arn
  app_statements    = {}
}