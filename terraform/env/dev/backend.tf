########################################
# Terraform Remote Backend Configuration
########################################

terraform {
  backend "s3" {
    # 🔹 Name of the S3 bucket for remote state storage
    bucket = "my-bucket-manish-9902"

    # 🔹 Path to store the state file (per environment)
    key = "env/dev/terraform.tfstate"

    # 🔹 AWS region where the S3 bucket is created
    region = "us-east-1"

    use_lockfile = true
  }
}
