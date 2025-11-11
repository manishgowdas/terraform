########################################
# S3 Module Inputs
########################################

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable object versioning for the bucket"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "force_destroy" {
  description = "Force destroy bucket and remove objects on destroy"
  type        = bool
  default     = false
}

variable "attach_policy" {
  description = "Whether to attach a custom bucket policy"
  type        = bool
  default     = false
}

variable "bucket_policy" {
  description = "Bucket policy JSON (string). Only used when attach_policy = true"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}
