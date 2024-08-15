locals { # TODO: THESE RULES HAVE TO BE REVISED
  remote_node_roles          = [for env, account_id in var.sdlc_account_ids : "arn:aws:iam::${account_id}:role/${var.node_role_name}"]
  remote_node_roles_dev_only = ["arn:aws:iam::${var.sdlc_account_ids["development"]}:role/${var.node_role_name}"]

  rules = [
    {
      rulePriority = 10
      description  = "Keeping the 100 most recent images tagged with prefix 'stable'"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = ["stable"]
        countType     = "imageCountMoreThan"
        countNumber   = 100
      }
    },
    {
      rulePriority = 20
      description  = "Keeping the ${var.ecr_image_count} most recent images regardless of their tags"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.ecr_image_count
      }
    },
  ]
}