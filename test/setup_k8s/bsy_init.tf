locals {
  barney_namespace = "barney"
  containers_num   = 2
}

resource "kubernetes_namespace" "barney" {
  metadata {
    annotations = {
      name = local.barney_namespace
    }

    labels = {
      environment = "production"
      name        = "barney"
    }
    name = local.barney_namespace
  }
}

#---------------------------------------------------------------------------------------

# data "kubernetes_nodes" "per_label" {
#   for_each = toset(["barney", "bus", "barney-aux"])
#   metadata{
#     labels = {
#       "node-role/${each.key}" = "${each.key}"
#     }
#   }
#   depends_on = [kubernetes_namespace.barney, ]
# }

# resource "kubernetes_node_taint" "barney_bsy" {
#   for_each = toset(data.kubernetes_nodes.per_label["barney"].nodes)
#   metadata {
#     name = each.value.metadata.0.name
#   }
#   taint {
#     key    = "type=barney"
#     value  = "true"
#     effect = "NoSchedule"
#   }
#   depends_on = [kubernetes_namespace.barney, ]
# }

# resource "kubernetes_node_taint" "barney_aux" {
#   for_each = toset(data.kubernetes_nodes.per_label["barney-aux"].nodes)
#   metadata {
#     name = each.value.metadata.0.name
#   }
#   taint {
#     key    = "type=barney_aux"
#     value  = "true"
#     effect = "NoSchedule"
#   }
#   depends_on = [kubernetes_namespace.barney, ]
# }

# resource "kubernetes_node_taint" "barney_bus" {
#   for_each = toset(data.kubernetes_nodes.per_label["bus"].nodes)
#   metadata {
#     name = each.value.metadata.0.name
#   }
#   taint {
#     key    = "type=bus"
#     value  = "true"
#     effect = "NoSchedule"
#   }
#   depends_on = [kubernetes_namespace.barney, ]
# }


#---------------------------------------------------------------------------------------

resource "kubernetes_manifest" "secret_barney_bsy_git_credentials" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "git-credentials" = "YWJjZAo="
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/app"     = "bsy"
        "app.kubernetes.io/name"    = "bsy"
        "app.kubernetes.io/part-of" = "barney"
      }
      "name"      = "bsy-git-credentials"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}

resource "kubernetes_manifest" "secret_barney_bsy_secrets" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "B5_HOST_SETTINGS_SECRETS_JENKINS" = "YWJjZGVmZw=="
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/app"  = "barney-bsy"
        "app.kubernetes.io/name" = "bsy-secrets"
      }
      "name"      = "bsy-secrets"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}

#---------------------------------------------------------------------------------------
# Secrets for Barney Topic Manager BTM

resource "kubernetes_manifest" "barney--btm-firestore-credentials--infra" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "barney--btm-firestore-credentials--infra" = "YWJjZAo="
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/app"  = "barney-bsy"
        "app.kubernetes.io/name" = "bsy-secrets"
      }
      "name"      = "barney--btm-firestore-credentials--infra"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}

resource "kubernetes_manifest" "barney--btm-github-username--infra" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "barney--btm-github-username--infra" = "YWJjZAo="
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/app"  = "barney-bsy"
        "app.kubernetes.io/name" = "bsy-secrets"
      }
      "name"      = "barney--btm-github-username--infra"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}

resource "kubernetes_manifest" "barney--btm-github-password--infra" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "barney--btm-github-password--infra" = "YWJjZAo="
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/app"  = "barney-bsy"
        "app.kubernetes.io/name" = "bsy-secrets"
      }
      "name"      = "barney--btm-github-password--infra"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}

resource "kubernetes_manifest" "barney--jenkins-api-token--infra" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "barney--jenkins-api-token--infra" = "YWJjZAo="
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/app"  = "barney-bsy"
        "app.kubernetes.io/name" = "bsy-secrets"
      }
      "name"      = "barney--jenkins-api-token--infra"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}

resource "kubernetes_manifest" "barney--srv_bessy_gerrit_token--infra" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "GERRIT_USER"                                           = "c3J2LWJlc3N5Cg=="
      "GERRIT_PASSWORD_gerrit.corp.arista.io"                 = "YWJjZAo="
      "GERRIT_PASSWORD_horseland-gerrit.infra.corp.arista.io" = "YWJjZAo="
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/app"     = "bsy"
        "app.kubernetes.io/name"    = "bsy"
        "app.kubernetes.io/part-of" = "barney"
      }
      "name"      = "barney--srv-bessy-gerrit-token--infra"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}

#---------------------------------------------------------------------------------------
# Secrets for BSY (Barney Snapshot Yielder)

resource "kubernetes_manifest" "arista_srv_bessy_github_token" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "scheme" = "aHR0cHMK"
      "host"   = "Z2l0aHViLmNvbQo="
      "user"   = "YXJpc3RhLXNydi1iZXNzeQo="
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/app"     = "bsy"
        "app.kubernetes.io/name"    = "bsy"
        "app.kubernetes.io/part-of" = "barney"
      }
      "name"      = "arista-srv-bessy-github-token"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}

resource "kubernetes_manifest" "srv_bessy_gerrit_token" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "scheme" = "aHR0cHMK"
      "host"   = "Z2Vycml0LmNvcnAuYXJpc3RhLmlvCg=="
      "user"   = "c3J2LWJlc3N5Cg=="
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/app"     = "bsy"
        "app.kubernetes.io/name"    = "bsy"
        "app.kubernetes.io/part-of" = "barney"
      }
      "name"      = "srv-bessy-gerrit-token"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}

resource "kubernetes_manifest" "srv_bessy_horseland_gerrit_token" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "scheme" = "aHR0cHMK"
      "host"   = "aG9yc2VsYW5kLWdlcnJpdC5jb3JwLmFyaXN0YS5pbwo="
      "user"   = "c3J2LWJlc3N5Cg=="
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/app"     = "bsy"
        "app.kubernetes.io/name"    = "bsy"
        "app.kubernetes.io/part-of" = "barney"
      }
      "name"      = "srv-bessy-horseland-gerrit-token"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}

#---------------------------------------------------------------------------------------

resource "kubernetes_manifest" "barney_rsvp_p4togit_ssh_key" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "ssh-privatekey" = "aHR0cHMK" # arvault : barney--rsvp-p4togit-ssh-key--infra
    }
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "maintainer" = "barney-dev@arista.com"
      }
      "labels" = {
        "app.kubernetes.io/name" = "barney-rsvp-p4togit-cron"
      }
      "name"      = "barney-rsvp-p4togit-ssh-key"
      "namespace" = "barney"
    }
    "type" = "Opaque"
  }
  depends_on = [kubernetes_namespace.barney, ]
}



#---------------------------------------------------------------------------------------

resource "kubernetes_manifest" "pod_nginx" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Pod"
    "metadata" = {
      "labels" = {
        "env" = "test"
      }
      "name"      = "nginx"
      "namespace" = "barney"
    }
    "spec" = {
      "containers" = [
        {
          "image"           = "nginx"
          "imagePullPolicy" = "IfNotPresent"
          "name"            = "nginx"
        },
      ]
    }
  }
  depends_on = [
    kubernetes_namespace.barney,
  ]
}


# create auth through namespace in here ?
