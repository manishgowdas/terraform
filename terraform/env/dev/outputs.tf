########################################
# ENVIRONMENT OUTPUTS (FINAL)
########################################

############################
# NETWORKING OUTPUTS
############################
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

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs created by networking module"
  value       = try(module.networking.nat_gateway_ids, [])
}

############################
# BASTION OUTPUTS
############################
output "bastion_instance_id" {
  description = "Bastion EC2 instance ID"
  value       = try(module.bastion.instance_id, null)
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion host"
  value       = try(module.bastion.public_ip, null)
}

output "bastion_security_group_id" {
  description = "Security Group ID of the Bastion instance"
  value       = try(module.bastion.security_group_id, null)
}

############################
# EKS OUTPUTS
############################
output "eks_cluster_names" {
  description = "List of all EKS cluster names"
  value       = try(module.eks.cluster_names, [])
}

output "eks_cluster_arns" {
  description = "Map of EKS cluster names to their ARNs"
  value       = try(module.eks.cluster_arns, {})
}

output "eks_cluster_endpoints" {
  description = "Map of EKS cluster names to their API endpoints"
  value       = try(module.eks.cluster_endpoints, {})
}

output "eks_cluster_certificate_authorities" {
  description = "Map of EKS cluster names to their CA data"
  value       = try(module.eks.cluster_certificate_authorities, {})
}

output "eks_node_group_names" {
  description = "List of all node group names across clusters"
  value       = try(module.eks.node_group_names, [])
}

output "eks_cluster_info" {
  description = "Summary of each EKS cluster with metadata and addons"
  value       = try(module.eks.eks_cluster_info, {})
}

############################
# RDS OUTPUTS
############################
output "rds_endpoint" {
  description = "RDS endpoint (hostname:port)"
  value       = try(module.rds.endpoint, null)
}

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = try(module.rds.instance_id, null)
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = try(module.rds.rds_sg_id, null)
}

############################
# S3 OUTPUTS
############################
output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = try(module.s3.bucket_name, null)
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = try(module.s3.bucket_arn, null)
}

############################
# HELM DEPLOYMENTS
############################
output "metric_server_status" {
  description = "Metric Server Helm release status"
  value       = try("${module.metric_server.release_name} (ns: ${module.metric_server.namespace})", "Metrics Server not deployed")
}

output "cluster_autoscaler_status" {
  description = "Cluster Autoscaler Helm release status"
  value       = try("${module.cluster_autoscaler.release_name} (ns: ${module.cluster_autoscaler.namespace})", "Cluster Autoscaler not deployed")
}

output "argocd_status" {
  description = "ArgoCD Helm release status"
  value       = try("${module.argocd.release_name} (ns: ${module.argocd.namespace})", "ArgoCD not deployed")
}

############################
# ENVIRONMENT SUMMARY
############################
output "environment_summary" {
  description = "Summary of key infrastructure components for this environment"
  value = {
    vpc_id              = module.networking.vpc_id
    eks_clusters        = try(module.eks.cluster_names, [])
    bastion_public_ip   = try(module.bastion.public_ip, null)
    rds_endpoint        = try(module.rds.endpoint, null)
    s3_bucket           = try(module.s3.bucket_name, null)
    metric_server_chart = try(module.metric_server.release_name, null)
    autoscaler_chart    = try(module.cluster_autoscaler.release_name, null)
    argocd_chart        = try(module.argocd.release_name, null)
  }
}

