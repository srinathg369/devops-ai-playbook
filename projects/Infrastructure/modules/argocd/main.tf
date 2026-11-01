resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
    }
  }
}


resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  # Local copy of argo-cd 6.7.0 from https://argoproj.github.io/argo-helm.
  # Terraform's Helm plugin timed out downloading it from GitHub.
  chart = "${path.module}/charts/argo-cd-6.7.0.tgz"

  create_namespace = false

  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP" 
        }
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]
}

resource "helm_release" "monitoring" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  # Local copy of kube-prometheus-stack 56.21.0 from
  # https://prometheus-community.github.io/helm-charts
  chart = "${path.module}/charts/kube-prometheus-stack-56.21.0.tgz"

  timeout          = 600
  create_namespace = false

  values = [
    yamlencode({
      grafana = {
        service = {
          type = "ClusterIP"
        }
      }

      prometheus = {
        service = {
          type = "ClusterIP"
        }
      }

      alertmanager = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring
  ]
}
