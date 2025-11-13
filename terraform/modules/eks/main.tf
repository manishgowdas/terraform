########################################
# EKS - Flexible Multi-Cluster Creation
########################################

########################################
# EKS Cluster(s)
########################################
resource "aws_eks_cluster" "this" {
  for_each = local.eks_clusters

  name     = each.value.name
  version  = each.value.version
  role_arn = aws_iam_role.eks_cluster[each.key].arn
  tags     = each.value.tags

  vpc_config {
    subnet_ids              = each.value.subnet_ids
    security_group_ids      = each.value.cluster_security_group_ids
    endpoint_private_access = each.value.endpoint_private_access
    endpoint_public_access  = each.value.endpoint_public_access
  }

  access_config {
    authentication_mode                         = var.cluster_authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy
  ]
}

########################################
# Node Groups (Per Cluster)
########################################
resource "aws_eks_node_group" "this" {
  for_each = local.eks_clusters

  cluster_name    = aws_eks_cluster.this[each.key].name
  node_group_name = "${each.value.name}-ng"
  node_role_arn   = aws_iam_role.eks_node[each.key].arn
  subnet_ids      = each.value.subnet_ids
  capacity_type   = lookup(each.value, "capacity_type", "ON_DEMAND")

  dynamic "scaling_config" {
    for_each = each.value.node_groups
    content {
      desired_size = scaling_config.value.desired_capacity
      min_size     = scaling_config.value.min_size
      max_size     = scaling_config.value.max_size
    }
  }

  instance_types = flatten([for ng in each.value.node_groups : ng.instance_types])

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  # ✅ Added autoscaler discovery tags
  tags = merge(
    each.value.tags,
    {
      NodeGroup                                      = "${each.value.name}-ng"
      "k8s.io/cluster-autoscaler/enabled"            = "true"
      "k8s.io/cluster-autoscaler/${each.value.name}" = "owned"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly
  ]
}

