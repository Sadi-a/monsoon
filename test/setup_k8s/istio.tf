locals {
  istio_charts_url = "https://istio-release.storage.googleapis.com/charts"
  istio_version    = "1.20.1"
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    annotations = {
      name = "istio-system"
    }
    labels = {
      environment = "production"
      name        = "istio-system"
    }
  }
}

resource "helm_release" "istio-base" {
  repository = local.istio_charts_url
  chart      = "base"
  name       = "istio-base"
  namespace  = kubernetes_namespace.istio_system.metadata.0.name
  version    = local.istio_version
}

resource "helm_release" "istiod" {
  repository = local.istio_charts_url
  chart      = "istiod"
  name       = "istiod"
  namespace  = kubernetes_namespace.istio_system.metadata.0.name
  version    = local.istio_version
  depends_on = [helm_release.istio-base]
}
