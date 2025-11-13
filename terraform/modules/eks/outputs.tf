########################################
# EKS CLUSTER OUTPUTS (Multi-Cluster)
########################################

# List of all EKS cluster names
output "cluster_names" {
  description = "List of all EKS cluster names"
  value       = [for k, v in aws_eks_cluster.this : v.name]
}

# Map of EKS cluster names to ARNs
output "cluster_arns" {
  description = "Map of EKS cluster names to their ARNs"
  value       = { for k, v in aws_eks_cluster.this : k => v.arn }
}

# Map of EKS cluster names to API endpoints
output "cluster_endpoints" {
  description = "Map of EKS cluster names to their API endpoints"
  value       = { for k, v in aws_eks_cluster.this : k => v.endpoint }
}

# Map of EKS cluster names to base64-encoded certificate authorities
output "cluster_certificate_authorities" {
  description = "Map of EKS cluster names to their base64-encoded CA data"
  value       = { for k, v in aws_eks_cluster.this : k => try(v.certificate_authority[0].data, null) }
}

########################################
# NODE GROUP OUTPUTS
########################################

output "node_group_names" {
  description = "List of EKS node group names across all clusters"
  value       = [for ng in aws_eks_node_group.this : ng.node_group_name]
}

output "node_group_arns" {
  description = "List of EKS node group ARNs across all clusters"
  value       = [for ng in aws_eks_node_group.this : ng.arn]
}

########################################
# ADDON OUTPUTS (driven from var.eks_clusters)
########################################

output "addons_enabled" {
  description = "Map of clusters and whether addons are enabled"
  value       = { for cluster in var.eks_clusters : cluster.name => cluster.enable_addons }
}

output "addons_config" {
  description = "Map of cluster names to their addon configuration from tfvars"
  value       = { for cluster in var.eks_clusters : cluster.name => cluster.addons }
}

output "addons_status" {
  description = "Addon deployment status per cluster (addon -> deployed version or null)"
  value = {
    for cluster in var.eks_clusters :
    cluster.name => {
      vpc_cni      = try(aws_eks_addon.vpc_cni[cluster.name].addon_version, null)
      coredns      = try(aws_eks_addon.coredns[cluster.name].addon_version, null)
      kube_proxy   = try(aws_eks_addon.kube_proxy[cluster.name].addon_version, null)
      pod_identity = try(aws_eks_addon.pod_identity[cluster.name].addon_version, null)
      ebs_csi      = try(aws_eks_addon.ebs_csi_driver[cluster.name].addon_version, null)
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
# SUMMARY OUTPUT
########################################

output "eks_cluster_info" {
  description = "Summary map of each cluster's main metadata and networking"
  value = {
    for name, cluster in aws_eks_cluster.this :
    name => {
      arn      = cluster.arn
      endpoint = cluster.endpoint
      version  = cluster.version
      vpc_id   = try(cluster.vpc_config[0].vpc_id, null)
      subnets  = try(cluster.vpc_config[0].subnet_ids, [])
      addons   = lookup({ for c in var.eks_clusters : c.name => c.addons }, name, {})
    }
  }
}

