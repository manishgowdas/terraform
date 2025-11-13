variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

variable "db_subnets" {
  description = "List of CIDR blocks and AZs for isolated RDS subnets"
  type = list(object({
    cidr = string
    az   = string
  }))
}

variable "app_sg_id" {
  description = "Application SG ID allowed to access RDS"
  type        = string
  default     = ""
}

variable "db_engine" {
  description = "Database engine (postgres, mysql)"
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
  description = "Allocated storage in GB"
  type        = number
}

variable "db_storage_type" {
  description = "Storage type (gp3, gp2, io1)"
  type        = string
}

variable "db_username" {
  description = "Admin username"
  type        = string
}

variable "db_password" {
  description = "Admin password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "DB port number"
  type        = number
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "Prevent accidental deletion"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

