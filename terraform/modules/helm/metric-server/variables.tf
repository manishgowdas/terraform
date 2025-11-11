##########################################
# Metrics Server Helm Variables
##########################################

variable "name" {
  description = "Helm release name for Metrics Server"
  type        = string
}

variable "repository" {
  description = "Helm repository URL for Metrics Server"
  type        = string
  default     = "https://kubernetes-sigs.github.io/metrics-server/"
}

variable "chart" {
  description = "Helm chart name"
  type        = string
  default     = "metrics-server"
}

variable "chart_version" {
  description = "Version of the Helm chart to deploy"
  type        = string
  default     = "3.12.2"
}

variable "namespace" {
  description = "Namespace for Metrics Server"
  type        = string
  default     = "kube-system"
}

variable "create_namespace" {
  description = "Create namespace if not exists"
  type        = bool
  default     = false
}
