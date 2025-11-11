############################
# VPC Variables
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
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

############################
# Optional Names
############################

variable "igw_name" {
  description = "Optional name for the Internet Gateway"
  type        = string
  default     = ""
}

variable "nat_name" {
  description = "Optional name for the NAT Gateway"
  type        = string
  default     = ""
}

variable "public_rt_name" {
  description = "Optional name for the public route table"
  type        = string
  default     = ""
}

variable "private_rt_name" {
  description = "Optional name for the private route table"
  type        = string
  default     = ""
}

############################
# EKS Integration
############################

variable "enable_eks" {
  description = "Whether to enable EKS subnet tagging"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "EKS cluster name for tagging"
  type        = string
  default     = ""
}

variable "extra_subnet_tags" {
  description = "Map of additional subnet tags"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Common tags applied to networking resources"
  type        = map(string)
  default     = {}
}
