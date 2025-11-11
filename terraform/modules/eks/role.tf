########################################
# IAM ROLES FOR MULTI-CLUSTER EKS MODULE
########################################

locals {
  eks_clusters = { for cluster in var.eks_clusters : cluster.name => cluster }
}

########################################
# EKS CLUSTER IAM ROLE
########################################

resource "aws_iam_role" "eks_cluster" {
  for_each = local.eks_clusters

  name = "${each.value.name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(each.value.tags, { Name = "${each.value.name}-cluster-role" })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  for_each   = aws_iam_role.eks_cluster
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  for_each   = aws_iam_role.eks_cluster
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

########################################
# NODE GROUP IAM ROLE(S)
########################################

resource "aws_iam_role" "eks_node" {
  for_each = { for cluster in var.eks_clusters : cluster.name => cluster }

  name = "${each.value.name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(each.value.tags, { Name = "${each.value.name}-node-role" })
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  for_each   = aws_iam_role.eks_node
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  for_each   = aws_iam_role.eks_node
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  for_each   = aws_iam_role.eks_node
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

########################################
# CLUSTER AUTOSCALER IAM ROLE (Optional)
########################################

resource "aws_iam_role" "cluster_autoscaler" {
  for_each = {
    for cluster_name, cluster in local.eks_clusters :
    cluster_name => cluster if cluster.enable_addons && contains(keys(cluster.addons), "pod_identity")
  }

  name = "${each.key}-cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = merge(each.value.tags, { Name = "${each.key}-cluster-autoscaler-role" })
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  for_each = aws_iam_role.cluster_autoscaler

  name        = "${each.key}-ClusterAutoscalerPolicy"
  description = "Policy for Cluster Autoscaler"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeInstanceTypes"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_policy_attach" {
  for_each   = aws_iam_role.cluster_autoscaler
  role       = each.value.name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy[each.key].arn
}

########################################
# AMAZON EBS CSI DRIVER IAM ROLE (Optional)
########################################

resource "aws_iam_role" "ebs_csi_driver" {
  for_each = {
    for cluster_name, cluster in local.eks_clusters :
    cluster_name => cluster if cluster.enable_addons && contains(keys(cluster.addons), "ebs_csi_driver")
  }

  name = "${each.key}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = merge(each.value.tags, { Name = "${each.key}-ebs-csi-driver-role" })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attach" {
  for_each   = aws_iam_role.ebs_csi_driver
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
