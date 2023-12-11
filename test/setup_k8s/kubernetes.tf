locals {
  barney_namespace = "barney"
}

provider "kubernetes" {
  config_path = "../mercury-config"
}


resource "kubernetes_secret" "test" {
  metadata {
    name      = "git-creds"
    namespace = "barney"
  }

  data = {
    username = "Foo"
    password = "Bar"
  }

  type = "Opaque"
}

resource "kubernetes_namespace" "barney" {
  metadata {
    annotations = {
      name = local.barney_namespace
    }

    labels = {
      environment = "production"
    }
    name = local.barney_namespace
  }
}
