############################################
# BASTION HOST MODULE
############################################

############################################
# Fetch latest Amazon Linux 2 AMI
############################################
data "aws_ami" "bastion" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

############################################
# Security Group
############################################
resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group for Bastion Host"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_ssh_cidrs
    content {
      description = "Allow SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${var.name}-sg" }, var.tags)
}

############################################
# IAM ROLE (Optional for SSM)
############################################
resource "aws_iam_role" "this" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.name}-profile"
  role  = aws_iam_role.this[0].name
}

############################################
# SSH Key Pair Handling (Safe Create or Reuse)
############################################

locals {
  bastion_pub_key_path = "${path.module}/public_keys/${var.ssh_key_name}.pub"
  has_local_pub_key    = fileexists(local.bastion_pub_key_path)
}

# Generate a new key if no .pub file exists
resource "tls_private_key" "generated" {
  count     = local.has_local_pub_key ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create or register the AWS key pair
resource "aws_key_pair" "this" {
  key_name = var.ssh_key_name

  # ✅ Properly wrapped ternary for Terraform parser
  public_key = (
    local.has_local_pub_key
    ? file(local.bastion_pub_key_path)
    : tls_private_key.generated[0].public_key_openssh
  )

  lifecycle {
    ignore_changes = [public_key]
  }
}

# Save the private key locally if it was generated
resource "local_file" "private_key" {
  count    = local.has_local_pub_key ? 0 : 1
  filename = "${path.module}/generated_keys/${var.ssh_key_name}.pem"
  content  = tls_private_key.generated[0].private_key_pem

  file_permission = "0400"
}

# Final effective key name
locals {
  effective_key_name = var.enable_ssm ? null : aws_key_pair.this.key_name
}

############################################
# EC2 INSTANCE
############################################
resource "aws_instance" "this" {
  ami                         = data.aws_ami.bastion.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  key_name                    = local.effective_key_name
  iam_instance_profile        = var.enable_ssm ? aws_iam_instance_profile.this[0].name : null
  associate_public_ip_address = var.associate_public_ip_address

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  user_data = var.user_data != "" ? var.user_data : file("${path.module}/user_data.sh")

  tags = merge({ Name = var.name }, var.tags)
}

