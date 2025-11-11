########################################
# EKS CLUSTER OUTPUTS (Multi-Cluster)
########################################

output "cluster_names" {
  description = "List of all EKS cluster names"
  value       = [for k, v in aws_eks_cluster.this : v.name]
}

output "cluster_arns" {
  description = "Map of EKS cluster names to their ARNs"
  value       = { for k, v in aws_eks_cluster.this : k => v.arn }
}

output "cluster_endpoints" {
  description = "Map of EKS cluster names to their API endpoints"
  value       = { for k, v in aws_eks_cluster.this : k => v.endpoint }
}

output "cluster_certificate_authorities" {
  description = "Map of EKS cluster names to their base64-encoded CA data"
  value       = { for k, v in aws_eks_cluster.this : k => v.certificate_authority[0].data }
}

########################################
# NODE GROUP OUTPUTS (Per Cluster)
########################################

output "node_group_names" {
  description = "Map of cluster names to their node group names"
  value = {
    for cluster_name, ng in aws_eks_node_group.this :
    cluster_name => [for n in ng : n.node_group_name]
  }
}

output "node_group_arns" {
  description = "Map of cluster names to their node group ARNs"
  value = {
    for cluster_name, ng in aws_eks_node_group.this :
    cluster_name => [for n in ng : n.arn]
  }
}

########################################
# ADDON OUTPUTS
########################################

output "addons_enabled" {
  description = "Map of clusters and whether addons are enabled"
  value       = { for cluster in var.eks_clusters : cluster.name => cluster.enable_addons }
}

output "addons_config" {
  description = "Map of cluster names to their addon version configuration"
  value       = { for cluster in var.eks_clusters : cluster.name => cluster.addons }
}

output "addons_status" {
  description = "Addon deployment status per cluster (addon → version)"
  value = {
    for k, v in aws_eks_addon.vpc_cni :
    k => {
      vpc_cni      = try(aws_eks_addon.vpc_cni[k].addon_version, null)
      coredns      = try(aws_eks_addon.coredns[k].addon_version, null)
      kube_proxy   = try(aws_eks_addon.kube_proxy[k].addon_version, null)
      pod_identity = try(aws_eks_addon.pod_identity[k].addon_version, null)
      ebs_csi      = try(aws_eks_addon.ebs_csi_driver[k].addon_version, null)
    }
  }
}

########################################
# IAM ROLE OUTPUTS
########################################

output "iam_roles" {
  description = "All IAM roles used by EKS clusters and node groups"
  value = {
    cluster_roles       = { for k, v in aws_iam_role.eks_cluster : k => v.arn }
    node_group_roles    = { for k, v in aws_iam_role.eks_node : k => v.arn }
    cluster_autoscaler  = try(aws_iam_role.cluster_autoscaler[0].arn, null)
    ebs_csi_driver_role = try(aws_iam_role.ebs_csi_driver[0].arn, null)
  }
}

########################################
# POD IDENTITY & ADDON DEPENDENCIES
########################################

output "pod_identity_associations" {
  description = "Map of clusters to their Pod Identity associations for autoscaler and EBS CSI"
  value = {
    autoscaler = try(aws_eks_pod_identity_association.cluster_autoscaler[0].id, null)
    ebs_csi    = try(aws_eks_pod_identity_association.ebs_csi_driver[0].id, null)
  }
}

output "eks_cluster_info" {
  description = "Summary map of each cluster’s main metadata"
  value = {
    for name, cluster in aws_eks_cluster.this :
    name => {
      arn       = cluster.arn
      endpoint  = cluster.endpoint
      version   = cluster.version
      vpc_id    = cluster.vpc_config[0].vpc_id
      subnets   = cluster.vpc_config[0].subnet_ids
      addons    = lookup(var.addons, name, {})
      node_roles = [for ng in aws_iam_role.eks_node : ng.value.arn]
    }
  }
}
