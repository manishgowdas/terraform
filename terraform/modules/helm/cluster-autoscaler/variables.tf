########################################
# Cluster Autoscaler Helm Variables
########################################

variable "helm_name" {
  description = "Name of the Cluster Autoscaler Helm release"
  type        = string
  default     = "cluster-autoscaler"
}

variable "namespace" {
  description = "Namespace to install Cluster Autoscaler into"
  type        = string
  default     = "kube-system"
}

variable "chart_version" {
  description = "Version of the Cluster Autoscaler Helm chart"
  type        = string
  default     = "9.29.0"
}
variable "values" {
  description = "Custom Helm values for Cluster Autoscaler"
  type        = any
  default     = {}
}

