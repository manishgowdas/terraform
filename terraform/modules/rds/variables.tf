########################################
# INPUT VARIABLES
########################################

variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}

variable "env" {
  description = "Environment name for resource naming"
  type        = string
}

variable "app_sg_id" {
  description = "Application Security Group ID that can access the RDS instance"
  type        = string
}

variable "db_subnets" {
  description = "List of subnet definitions for RDS. Each element includes { cidr, az }"
  type = list(object({
    cidr = string
    az   = string
  }))
}

variable "db_engine" {
  description = "RDS database engine (e.g., postgres, mysql)"
  type        = string
}

variable "db_engine_version" {
  description = "RDS engine version"
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for RDS"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
}

variable "db_storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
}

variable "db_password" {
  description = "Master password for RDS (sensitive)"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Port number for database connection"
  type        = number
  default     = 5432
}

variable "db_multi_az" {
  description = "Enable Multi-AZ RDS deployment"
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for RDS instance"
  type        = bool
  default     = false
}
