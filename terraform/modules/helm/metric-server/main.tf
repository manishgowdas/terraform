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


##########################################
# Metrics Server Helm Installation
##########################################
resource "helm_release" "metric_server" {
  name             = var.name
  repository       = var.repository
  chart            = var.chart
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = var.create_namespace

  # Apply custom Helm values (if file exists)
  values = [file("${path.module}/values.yaml")]

  wait    = true
  timeout = 300
}

