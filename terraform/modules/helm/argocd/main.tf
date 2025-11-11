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

  # Apply Helm values from local file
  values = [
    file("${path.module}/values.yaml")
  ]

  wait            = true
  cleanup_on_fail = true
  timeout         = 600
}
