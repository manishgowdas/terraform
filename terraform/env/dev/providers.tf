#########################################
## Terraform Provider Configuration
#########################################
#
#terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 6.20"
#    }
#    kubernetes = {
#      source  = "hashicorp/kubernetes"
#      version = "~> 2.38"
#    }
#    helm = {
#      source  = "hashicorp/helm"
#      version = "~> 2.17"
#    }
#    local = {
#      source  = "hashicorp/local"
#      version = "~> 2.5"
#    }
#    null = {
#      source  = "hashicorp/null"
#      version = "~> 3.2"
#    }
#  }
#}
#
#########################################
## AWS Provider
#########################################
#
provider "aws" {
  region  = var.region
  #  profile = var.profile
}
#
#########################################
## EKS Data Sources (Safe Bootstrap)
#########################################
#
#locals {
#  primary_cluster_name = try(var.cluster_name, "dev-eks")
#}
#
## Only query the EKS cluster after it's created
#data "aws_eks_cluster" "eks" {
#  count      = can(module.eks.cluster_names[0]) ? 1 : 0
#  name       = can(module.eks.cluster_names[0]) ? module.eks.cluster_names[0] : local.primary_cluster_name
#  depends_on = [module.eks]
#}
#
#data "aws_eks_cluster_auth" "eks" {
#  count      = length(data.aws_eks_cluster.eks) > 0 ? 1 : 0
#  name       = try(module.eks.cluster_names[0], local.primary_cluster_name)
#  depends_on = [module.eks]
#}
#
#########################################
## Kubernetes Provider (for EKS)
#########################################
#
#provider "kubernetes" {
#  alias = "eks"
#
#  host                   = try(data.aws_eks_cluster.eks[0].endpoint, "")
#  cluster_ca_certificate = try(
#    base64decode(data.aws_eks_cluster.eks[0].certificate_authority[0].data),
#    ""
#  )
#  token = try(data.aws_eks_cluster_auth.eks[0].token, "")
#
#  load_config_file = false
#
#  experiments {
#    manifest_resource = true
#  }
#}
#
#########################################
## Helm Provider (for EKS)
#########################################
#
#provider "helm" {
#  alias = "eks"
#
#  kubernetes {
#    host                   = try(data.aws_eks_cluster.eks[0].endpoint, "")
#    cluster_ca_certificate = try(
#      base64decode(data.aws_eks_cluster.eks[0].certificate_authority[0].data),
#      ""
#    )
#    token = try(data.aws_eks_cluster_auth.eks[0].token, "")
#  }
#}
#
#########################################
## Local & Null Providers
#########################################
#
#provider "local" {}
#provider "null" {}
########################################
# Temporary Helm Provider for Cleanup
########################################

provider "helm" {
  alias = "eks"

  kubernetes {
    host                   = "https://placeholder"
    cluster_ca_certificate = ""
    token                  = ""
  }
}
#
