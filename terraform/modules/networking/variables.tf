########################################
# NETWORKING MODULE VARIABLES
########################################

############################
# VPC Configuration
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
  description = "List of availability zones for subnets"
  type        = list(string)
}

############################
# Subnets
############################

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

############################
# Optional Resource Names
############################

variable "igw_name" {
  description = "Optional custom name for Internet Gateway"
  type        = string
  default     = ""
}

variable "nat_name" {
  description = "Optional prefix name for NAT Gateway(s)"
  type        = string
  default     = ""
}

############################
# EKS Tagging Support
############################

variable "enable_eks" {
  description = "Whether to tag subnets for EKS"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS cluster name (used for subnet tagging)"
  type        = string
  default     = ""
}

variable "extra_subnet_tags" {
  description = "Additional tags for subnets (merged with defaults)"
  type        = map(string)
  default     = {}
}

############################
# Common Tags
############################

variable "tags" {
  description = "Common tags applied to all networking resources"
  type        = map(string)
  default     = {}
}

