resource "aws_security_group" "albc_backend_sg" {
  count       = var.enable_albc ? 1 : 0
  name        = "albc-backend-sg"
  description = "Security group for the ALBC backend, to provide access to individual exposed pods"
  vpc_id      = var.vpc_id

  tags = {
    "elbv2.k8s.aws/resource" = "backend-sg"
  }
}