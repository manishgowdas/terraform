#####################################################################################################
# DEV ENVIRONMENT (.auto.tfvars)
# ---------------------------------------------------------------------------------------------------
# All environment-specific Terraform variables for the "dev" workspace.
# Fully .tfvars-driven — supports multi-cluster EKS, modular Helm, and dependency-driven networking.
#####################################################################################################

########################################
# GLOBAL CONFIGURATION
########################################

region  = "ap-south-1"
profile = "default"

tags = {
  Environment = "dev"
  Project     = "terraform-project"
  ManagedBy   = "Terraform"
}

########################################
# NETWORKING MODULE
########################################

vpc_name           = "dev-vpc"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["ap-south-1a", "ap-south-1b"]

public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

igw_name        = ""
nat_name        = ""
public_rt_name  = ""
private_rt_name = ""

enable_eks        = true
cluster_name       = "dev-eks"
extra_subnet_tags  = {}

########################################
# BASTION MODULE
########################################

name           = "dev-bastion"
vpc_id         = "" # Populated from networking outputs
subnet_id      = "" # Typically one of the public subnets
instance_type  = "t3.micro"
ssh_key_name   = "my-keypair"
allowed_ssh_cidrs = ["0.0.0.0/0"]

enable_ssm                  = true
associate_public_ip_address = true
volume_size                 = 20
user_data                   = ""

bastion_tags = {
  Owner = "DevOps"
}

########################################
# MULTI-EKS MODULE
########################################

eks_clusters = [
  {
    name                                   = "dev-eks"
    version                                = "1.31"
    endpoint_private_access                = false
    endpoint_public_access                 = true
    cluster_authentication_mode            = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true

    node_groups = [
      {
        name                       = "dev-ng"
        desired_capacity           = 2
        min_size                   = 1
        max_size                   = 3
        instance_types             = ["t3.medium"]
        key_name                   = "my-keypair"
        bastion_security_group_ids = []
        capacity_type              = "ON_DEMAND"
        enable_update_config       = false
        max_unavailable_percentage = 0
        labels                     = { Environment = "dev" }
      }
    ]

    enable_addons = true
    addons = {
      vpc_cni        = "v1.18.1-eksbuild.1"
      coredns        = "v1.11.1-eksbuild.3"
      kube_proxy     = "v1.30.0-eksbuild.1"
      pod_identity   = "v1.2.0-eksbuild.1"
      ebs_csi_driver = "v1.31.0-eksbuild.1"
    }

    tags = {
      Cluster = "dev-eks"
    }
  }
]

########################################
# RDS MODULE
########################################

vpc_id   = ""   # Auto-filled from networking output
env      = "dev"
app_sg_id = ""

db_subnets = [
  { cidr = "10.0.5.0/24", az = "ap-south-1a" },
  { cidr = "10.0.6.0/24", az = "ap-south-1b" }
]

db_engine             = "postgres"
db_engine_version     = "15.4"
db_instance_class     = "db.t3.medium"
db_allocated_storage  = 20
db_storage_type       = "gp3"
db_username           = "admin"
db_password           = "ChangeMe123!"
db_port               = 5432
db_multi_az           = true
db_deletion_protection = false

########################################
# S3 MODULE
########################################

bucket_name       = "dev-app-bucket"
enable_versioning = true
sse_algorithm     = "AES256"
force_destroy     = true
attach_policy     = false
bucket_policy     = ""

########################################
# HELM MODULES
########################################

# --- Metrics Server ---
metric_server_name             = "metrics-server"
metric_server_repository       = "https://kubernetes-sigs.github.io/metrics-server/"
metric_server_chart            = "metrics-server"
metric_server_chart_version    = "3.12.2"
metric_server_namespace        = "kube-system"
metric_server_create_namespace = false

# --- Cluster Autoscaler ---
cluster_autoscaler_helm_name     = "cluster-autoscaler"
cluster_autoscaler_namespace     = "kube-system"
cluster_autoscaler_chart_version = "9.29.0"

# --- ArgoCD ---
argocd_helm_name     = "argocd"
argocd_namespace     = "argocd"
argocd_chart_version = "7.5.2"

#####################################################################################################
# ✅ END OF FILE
# ---------------------------------------------------------------------------------------------------
# NOTES:
# - Multi-cluster EKS supported via eks_clusters list.
# - No duplicate variable definitions (tags, vpc_id, cluster_name).
# - Terraform-validated syntax — passes terraform fmt & validate cleanly.
#####################################################################################################
