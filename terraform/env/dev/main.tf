#####################################################################################################
# MAIN - DEV ENVIRONMENT (Optimized & Fully .tfvars-driven)
#####################################################################################################

########################################
# NETWORKING
########################################
module "networking" {
  source             = "../../modules/networking"
  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets

  igw_name          = var.igw_name
  nat_name          = var.nat_name
  enable_eks        = var.enable_eks
  cluster_name      = var.cluster_name
  extra_subnet_tags = var.extra_subnet_tags
  tags              = var.tags
}

########################################
# BASTION HOST
########################################
module "bastion" {
  source                      = "../../modules/bastion"
  name                        = var.name
  vpc_id                      = module.networking.vpc_id
  subnet_id                   = element(module.networking.public_subnet_ids, 0)
  instance_type               = var.instance_type
  ssh_key_name                = var.ssh_key_name
  allowed_ssh_cidrs           = var.allowed_ssh_cidrs
  enable_ssm                  = var.enable_ssm
  associate_public_ip_address = var.associate_public_ip_address
  volume_size                 = var.volume_size
  user_data                   = var.user_data
  tags                        = merge(var.tags, { Component = "bastion" })

  depends_on = [module.networking]
}

########################################
# EKS CLUSTER (Multi-cluster Ready)
########################################
module "eks" {
  source = "../../modules/eks"

  eks_clusters = [
    {
      name                       = var.cluster_name
      version                    = var.cluster_version
      subnet_ids                 = module.networking.private_subnet_ids
      cluster_security_group_ids = var.cluster_security_group_ids
      endpoint_private_access    = var.endpoint_private_access
      endpoint_public_access     = var.endpoint_public_access
      enable_addons              = var.enable_addons
      addons                     = var.addons
      node_groups                = var.node_groups
      tags                       = merge(var.tags, { Component = "eks" })
    }
  ]

  depends_on = [module.networking]
}

########################################
# RDS DATABASE
########################################
module "rds" {
  source                 = "../../modules/rds"
  vpc_id                 = module.networking.vpc_id
  env                    = var.env
  app_sg_id              = var.app_sg_id
  db_subnets             = var.db_subnets
  db_engine              = var.db_engine
  db_engine_version      = var.db_engine_version
  db_instance_class      = var.db_instance_class
  db_allocated_storage   = var.db_allocated_storage
  db_storage_type        = var.db_storage_type
  db_username            = var.db_username
  db_password            = var.db_password
  db_port                = var.db_port
  db_multi_az            = var.db_multi_az
  db_deletion_protection = var.db_deletion_protection
  tags                   = merge(var.tags, { Component = "rds" })

  depends_on = [module.networking]
}

########################################
# S3 BUCKET
########################################
module "s3" {
  source            = "../../modules/s3"
  bucket_name       = var.bucket_name
  enable_versioning = var.enable_versioning
  sse_algorithm     = var.sse_algorithm
  force_destroy     = var.force_destroy
  attach_policy     = var.attach_policy
  bucket_policy     = var.bucket_policy
  tags              = merge(var.tags, { Component = "s3" })
}

########################################
# HELM MODULES (Cluster Add-ons)
########################################

# --- Metrics Server ---
module "metric_server" {
  source           = "../../modules/helm/metric-server"
  name             = var.metric_server_name
  repository       = var.metric_server_repository
  chart            = var.metric_server_chart
  chart_version    = var.metric_server_chart_version
  namespace        = var.metric_server_namespace
  create_namespace = var.metric_server_create_namespace

  providers = {
    helm = helm.eks
  }

  depends_on = [module.eks]
}

# --- Cluster Autoscaler ---
module "cluster_autoscaler" {
  source        = "../../modules/helm/cluster-autoscaler"
  helm_name     = var.cluster_autoscaler_helm_name
  namespace     = var.cluster_autoscaler_namespace
  chart_version = var.cluster_autoscaler_chart_version
  values        = var.autoscaler_values

  providers = {
    helm = helm.eks
  }

  depends_on = [module.eks]
}

# --- ArgoCD ---
module "argocd" {
  source        = "../../modules/helm/argocd"
  helm_name     = var.argocd_helm_name
  namespace     = var.argocd_namespace
  chart_version = var.argocd_chart_version
  values        = var.argocd_values

  providers = {
    helm = helm.eks
  }

  depends_on = [module.eks]
}

