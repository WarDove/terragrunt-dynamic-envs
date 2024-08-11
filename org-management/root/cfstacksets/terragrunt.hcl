include "root" {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../organization"]
}

terraform {
  source = "../../../modules/cfstacksets"
}
