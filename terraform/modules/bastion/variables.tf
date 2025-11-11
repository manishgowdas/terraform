variable "name" {
  description = "Name prefix for Bastion resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Bastion host will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch Bastion instance (public subnet preferred)"
  type        = string
}

variable "instance_type" {
  description = "Instance type for Bastion"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "EC2 Key Pair name for SSH access (leave empty if using SSM only)"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into Bastion"
  type        = list(string)
  default     = []
}

variable "enable_ssm" {
  description = "Enable SSM (Session Manager) access"
  type        = bool
  default     = true
}

variable "associate_public_ip_address" {
  description = "Attach public IP to Bastion instance"
  type        = bool
  default     = true
}

variable "volume_size" {
  description = "EBS root volume size (GB)"
  type        = number
  default     = 20
}

variable "user_data" {
  description = "User data script path or inline content"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}
