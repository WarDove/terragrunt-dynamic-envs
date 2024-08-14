resource "kubernetes_namespace" "example" {
  metadata {
    annotations = {
      name = "it-works"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "terraform-example-namespace"
  }
}