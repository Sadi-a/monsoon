locals {
  config_path = "../mercury-config"
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }
}

provider "kubernetes" {
  config_path = local.config_path
}
