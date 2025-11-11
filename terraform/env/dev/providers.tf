########################################
# Terraform Provider Configuration
########################################

# --- AWS Provider ---
provider "aws" {
  region  = var.region
  profile = var.profile
}

# --- EKS Data Sources ---
# Used by both Kubernetes & Helm providers
data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

# --- Kubernetes Provider ---
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# --- Helm Provider ---
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

# --- Local Provider ---
provider "local" {}

# --- Null Provider ---
provider "null" {}
