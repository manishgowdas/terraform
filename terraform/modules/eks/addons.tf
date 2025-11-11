########################################
# EKS ADDONS (Multi-Cluster, .tfvars-driven)
########################################

locals {
  # Create a map of cluster name → cluster object
  eks_clusters = { for cluster in var.eks_clusters : cluster.name => cluster }
}

########################################
# Amazon VPC CNI Addon
########################################
resource "aws_eks_addon" "vpc_cni" {
  for_each = {
    for name, cluster in local.eks_clusters :
    name => cluster if cluster.enable_addons
  }

  cluster_name      = aws_eks_cluster.this[each.key].name
  addon_name        = "vpc-cni"
  addon_version     = lookup(each.value.addons, "vpc_cni", lookup(var.default_addons, "vpc_cni", "v1.18.1-eksbuild.1"))
  resolve_conflicts = "OVERWRITE"
  tags              = merge(each.value.tags, { Name = "${each.key}-vpc-cni" })

  depends_on = [aws_eks_cluster.this]
}

########################################
# CoreDNS Addon
########################################
resource "aws_eks_addon" "coredns" {
  for_each = {
    for name, cluster in local.eks_clusters :
    name => cluster if cluster.enable_addons
  }

  cluster_name      = aws_eks_cluster.this[each.key].name
  addon_name        = "coredns"
  addon_version     = lookup(each.value.addons, "coredns", lookup(var.default_addons, "coredns", "v1.11.1-eksbuild.3"))
  resolve_conflicts = "OVERWRITE"
  tags              = merge(each.value.tags, { Name = "${each.key}-coredns" })

  depends_on = [aws_eks_cluster.this]
}

########################################
# kube-proxy Addon
########################################
resource "aws_eks_addon" "kube_proxy" {
  for_each = {
    for name, cluster in local.eks_clusters :
    name => cluster if cluster.enable_addons
  }

  cluster_name      = aws_eks_cluster.this[each.key].name
  addon_name        = "kube-proxy"
  addon_version     = lookup(each.value.addons, "kube_proxy", lookup(var.default_addons, "kube_proxy", "v1.30.0-eksbuild.1"))
  resolve_conflicts = "OVERWRITE"
  tags              = merge(each.value.tags, { Name = "${each.key}-kube-proxy" })

  depends_on = [aws_eks_cluster.this]
}

########################################
# Pod Identity Agent Addon
########################################
resource "aws_eks_addon" "pod_identity" {
  for_each = {
    for name, cluster in local.eks_clusters :
    name => cluster if cluster.enable_addons
  }

  cluster_name      = aws_eks_cluster.this[each.key].name
  addon_name        = "eks-pod-identity-agent"
  addon_version     = lookup(each.value.addons, "pod_identity", lookup(var.default_addons, "pod_identity", "v1.2.0-eksbuild.1"))
  resolve_conflicts = "OVERWRITE"
  tags              = merge(each.value.tags, { Name = "${each.key}-pod-identity-agent" })

  depends_on = [aws_eks_cluster.this]
}

########################################
# Amazon EBS CSI Driver Addon
########################################
resource "aws_eks_addon" "ebs_csi_driver" {
  for_each = {
    for name, cluster in local.eks_clusters :
    name => cluster if cluster.enable_addons
  }

  cluster_name      = aws_eks_cluster.this[each.key].name
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = lookup(each.value.addons, "ebs_csi_driver", lookup(var.default_addons, "ebs_csi_driver", "v1.31.0-eksbuild.1"))
  resolve_conflicts = "OVERWRITE"
  tags              = merge(each.value.tags, { Name = "${each.key}-ebs-csi-driver" })

  depends_on = [aws_eks_cluster.this]
}
