########################################
# Terraform Provider Requirements
########################################
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
}


########################################
# ArgoCD Helm Chart Installation
########################################

resource "helm_release" "argocd" {
  name             = var.helm_name
  namespace        = var.namespace
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  create_namespace = true

  values = [yamlencode(var.values)]

  wait            = true
  cleanup_on_fail = true
  timeout         = 600
}

