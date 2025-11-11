########################################
# Terraform & Provider Version Locking
########################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.20"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
