locals {
  deployments          = toset(var.deployments)
  remote_fargate_roles = [for account_name, account_id in var.sdlc_account_ids : "arn:aws:iam::${account_id}:role/${var.company_prefix}-${account_name}-fargate-pod-execution-role"]
  remote_node_roles    = [for account_name, account_id in var.sdlc_account_ids : "arn:aws:iam::${account_id}:role/${var.company_prefix}-${account_name}-node-pod-execution-role"]
  remote_access_roles  = concat(local.remote_fargate_roles, local.remote_node_roles)
}
