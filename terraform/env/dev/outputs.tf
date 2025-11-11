#####################################################################################################
# ENVIRONMENT OUTPUTS - DEV
# ---------------------------------------------------------------------------------------------------
# Consolidates outputs from all environment modules for visibility, validation, and reuse.
#####################################################################################################

########################################
# NETWORKING OUTPUTS
########################################
output "vpc_id" {
  description = "VPC ID created by the networking module"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

########################################
# BASTION OUTPUTS
########################################
output "bastion_instance_id" {
  description = "EC2 Instance ID of the Bastion host"
  value       = try(module.bastion.instance_id, null)
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion host"
  value       = try(module.bastion.public_ip, null)
}

output "bastion_security_group_id" {
  description = "Security Group ID of the Bastion instance"
  value       = try(module.bastion.security_group_id, null)
}

########################################
# MULTI-EKS OUTPUTS
########################################
output "eks_clusters" {
  description = "Details of all deployed EKS clusters"
  value = {
    for k, eks_mod in module.eks :
    k => {
      cluster_name     = eks_mod.cluster_name
      cluster_endpoint = eks_mod.cluster_endpoint
      cluster_arn      = eks_mod.cluster_arn
      node_group_names = eks_mod.node_group_names
    }
  }
}

output "eks_cluster_kubeconfigs" {
  description = "Base64 encoded certificate authorities for all EKS clusters"
  value = {
    for k, eks_mod in module.eks :
    k => eks_mod.cluster_certificate_authority_data
  }
}

########################################
# RDS OUTPUTS
########################################
output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = try(module.rds.rds_endpoint, null)
}

output "rds_security_group_id" {
  description = "Security Group ID used by the RDS instance"
  value       = try(module.rds.rds_sg_id, null)
}

########################################
# S3 OUTPUTS
########################################
output "s3_bucket_name" {
  description = "S3 bucket name created for application data or logs"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

########################################
# HELM OUTPUTS
########################################
output "metric_server_status" {
  description = "Metric Server Helm release deployment status"
  value       = "Deployed successfully in ${try(module.metric_server.namespace, "kube-system")}"
}

output "cluster_autoscaler_status" {
  description = "Cluster Autoscaler Helm release deployment status"
  value       = "Deployed successfully in ${try(module.cluster_autoscaler.namespace, "kube-system")}"
}

output "argocd_status" {
  description = "ArgoCD Helm release deployment status"
  value       = "Deployed successfully in ${try(module.argocd.namespace, "argocd")}"
}

#####################################################################################################
# END OF FILE
#####################################################################################################
