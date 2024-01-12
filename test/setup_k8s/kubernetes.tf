locals {
  config_path = "../mercury-config"
}

provider "kubernetes" {
  config_path = local.config_path
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }
}
