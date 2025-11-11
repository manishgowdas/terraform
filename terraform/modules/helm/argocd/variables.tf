########################################
# ArgoCD Helm Chart Variables
########################################

variable "helm_name" {
  description = "Name of the ArgoCD Helm release"
  type        = string
  default     = "argocd"
}

variable "namespace" {
  description = "Namespace to install ArgoCD into"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "7.5.2"
}
