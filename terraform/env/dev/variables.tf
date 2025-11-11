########################################
# Environment Variables (env/dev)
########################################

############################
# AWS / Global Config
############################
variable "region" {
  description = "AWS region for all resources"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile for credentials"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

############################
# Networking (VPC, Subnets)
############################
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zones to use"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "igw_name" {
  description = "Name of Internet Gateway (optional)"
  type        = string
  default     = ""
}

variable "nat_name" {
  description = "Name of NAT Gateway (optional)"
  type        = string
  default     = ""
}

variable "public_rt_name" {
  description = "Public Route Table name (optional)"
  type        = string
  default     = ""
}

variable "private_rt_name" {
  description = "Private Route Table name (optional)"
  type        = string
  default     = ""
}

variable "enable_eks" {
  description = "Whether to tag subnets for EKS"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS Cluster name for subnet tagging (if applicable)"
  type        = string
  default     = ""
}

variable "extra_subnet_tags" {
  description = "Additional subnet tags if required"
  type        = map(string)
  default     = {}
}

############################
# Bastion
############################
variable "name" {
  description = "Bastion name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the Bastion host"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID for Bastion instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "SSH Key Pair name for Bastion access"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed SSH access"
  type        = list(string)
  default     = []
}

variable "enable_ssm" {
  description = "Enable SSM Session Manager for Bastion"
  type        = bool
  default     = true
}

variable "associate_public_ip_address" {
  description = "Attach public IP to Bastion instance"
  type        = bool
  default     = true
}

variable "volume_size" {
  description = "EBS root volume size for Bastion"
  type        = number
  default     = 20
}

variable "user_data" {
  description = "Custom user data script path or inline script"
  type        = string
  default     = ""
}

############################
# Multi-EKS Configuration
############################
variable "eks_clusters" {
  description = "List of EKS clusters to deploy, each with its configuration"
  type = list(object({
    name                                   = string
    version                                = string
    cluster_security_group_ids             = optional(list(string), [])
    endpoint_private_access                = optional(bool, false)
    endpoint_public_access                 = optional(bool, true)
    cluster_authentication_mode            = optional(string, "API_AND_CONFIG_MAP")
    bootstrap_cluster_creator_admin_permissions = optional(bool, true)
    node_groups = optional(list(object({
      name                       = string
      desired_capacity           = number
      min_size                   = number
      max_size                   = number
      instance_types             = list(string)
      key_name                   = string
      bastion_security_group_ids = optional(list(string), [])
      capacity_type              = optional(string)
      enable_update_config       = optional(bool, false)
      max_unavailable_percentage = optional(number, 0)
      labels                     = optional(map(string), {})
    })), [])
    enable_addons = optional(bool, true)
    addons = optional(map(string), {
      vpc_cni        = "v1.18.1-eksbuild.1"
      coredns        = "v1.11.1-eksbuild.3"
      kube_proxy     = "v1.30.0-eksbuild.1"
      pod_identity   = "v1.2.0-eksbuild.1"
      ebs_csi_driver = "v1.31.0-eksbuild.1"
    })
    tags = optional(map(string), {})
  }))
}

############################
# RDS
############################
variable "env" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

variable "app_sg_id" {
  description = "Application SG ID allowed to access RDS"
  type        = string
  default     = ""
}

variable "db_subnets" {
  description = "Subnet definitions for RDS (list of cidr/az)"
  type = list(object({
    cidr = string
    az   = string
  }))
}

variable "db_engine" {
  description = "Database engine (e.g. postgres, mysql)"
  type        = string
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage size (GB)"
  type        = number
}

variable "db_storage_type" {
  description = "RDS storage type (gp2, gp3, io1)"
  type        = string
}

variable "db_username" {
  description = "RDS admin username"
  type        = string
}

variable "db_password" {
  description = "RDS admin password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
}

############################
# S3
############################
variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "enable_versioning" {
  description = "Enable bucket versioning"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "S3 encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "force_destroy" {
  description = "Force destroy bucket"
  type        = bool
  default     = false
}

variable "attach_policy" {
  description = "Attach custom bucket policy"
  type        = bool
  default     = false
}

variable "bucket_policy" {
  description = "Bucket policy JSON if attach_policy = true"
  type        = string
  default     = ""
}

############################
# Helm Deployments
############################
variable "metric_server_name" {
  description = "Helm release name for metrics-server"
  type        = string
}

variable "metric_server_repository" {
  description = "Repository URL for metrics-server chart"
  type        = string
}

variable "metric_server_chart" {
  description = "Chart name for metrics-server"
  type        = string
}

variable "metric_server_version" {
  description = "Version of the metrics-server Helm chart"
  type        = string
}

variable "metric_server_namespace" {
  description = "Namespace for metrics-server deployment"
  type        = string
}

variable "metric_server_create_namespace" {
  description = "Whether to create namespace for metrics-server"
  type        = bool
}

variable "cluster_autoscaler_helm_name" {
  description = "Helm release name for cluster autoscaler"
  type        = string
}

variable "cluster_autoscaler_namespace" {
  description = "Namespace for cluster autoscaler"
  type        = string
}

variable "cluster_autoscaler_chart_version" {
  description = "Chart version for cluster autoscaler"
  type        = string
}

variable "argocd_helm_name" {
  description = "Helm release name for ArgoCD"
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
}

variable "argocd_chart_version" {
  description = "Chart version for ArgoCD"
  type        = string
}
