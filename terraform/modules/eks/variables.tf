########################################
# EKS MULTI-CLUSTER CONFIGURATION
########################################

variable "eks_clusters" {
  description = <<EOT
A list of EKS clusters to be created.
Each cluster object defines its version, networking, node groups, and addons.

Example:

eks_clusters = [
  {
    name                      = "dev-eks"
    version                   = "1.30"
    subnet_ids                = ["subnet-abc", "subnet-def"]
    cluster_security_group_ids = ["sg-xyz"]
    endpoint_private_access    = false
    endpoint_public_access     = true
    enable_addons              = true
    addons = {
      vpc_cni        = "v1.18.1-eksbuild.1"
      coredns        = "v1.11.1-eksbuild.3"
      kube_proxy     = "v1.30.0-eksbuild.1"
      pod_identity   = "v1.2.0-eksbuild.1"
      ebs_csi_driver = "v1.31.0-eksbuild.1"
    }

    node_groups = [
      {
        name             = "dev-ng"
        desired_capacity = 2
        min_size         = 1
        max_size         = 3
        instance_types   = ["t3.medium"]
        key_name         = "my-keypair"
        capacity_type    = "ON_DEMAND"
        labels           = { Environment = "dev" }
      }
    ]

    tags = {
      Environment = "dev"
      Project     = "terraform"
    }
  }
]
EOT

  type = list(object({
    name                       = string
    version                    = string
    subnet_ids                 = list(string)
    cluster_security_group_ids = list(string)
    endpoint_private_access    = bool
    endpoint_public_access     = bool
    enable_addons              = bool
    addons                     = map(string)
    node_groups = list(object({
      name             = string
      desired_capacity = number
      min_size         = number
      max_size         = number
      instance_types   = list(string)
      key_name         = string
      capacity_type    = string
      labels           = optional(map(string), {})
    }))
    tags = map(string)
  }))
}

########################################
# AUTHENTICATION & ACCESS CONFIGURATION
########################################

variable "cluster_authentication_mode" {
  description = "Cluster authentication mode (API_AND_CONFIG_MAP or CONFIG_MAP)"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Grant cluster creator admin permissions"
  type        = bool
  default     = true
}

########################################
# GLOBAL DEFAULTS (OPTIONAL)
########################################

variable "default_addons" {
  description = "Default addons applied when not defined at cluster level"
  type        = map(string)
  default = {
    vpc_cni        = "v1.18.1-eksbuild.1"
    coredns        = "v1.11.1-eksbuild.3"
    kube_proxy     = "v1.30.0-eksbuild.1"
    pod_identity   = "v1.2.0-eksbuild.1"
    ebs_csi_driver = "v1.31.0-eksbuild.1"
  }
}
