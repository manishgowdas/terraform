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
# Cluster Autoscaler Helm Installation
########################################
resource "helm_release" "cluster_autoscaler" {
  name             = var.helm_name
  namespace        = var.namespace
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = var.chart_version
  create_namespace = true

  values = [yamlencode(var.values)]

  wait            = true
  cleanup_on_fail = true
  timeout         = 600
}

