########################################
# Shared locals for EKS module
########################################

locals {
  eks_clusters = { for cluster in var.eks_clusters : cluster.name => cluster }
}

