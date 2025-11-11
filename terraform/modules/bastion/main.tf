############################################
# BASTION HOST MODULE
############################################

# Fetch latest Amazon Linux 2 AMI
data "aws_ami" "bastion" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

############################################
# SECURITY GROUP
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
# EC2 INSTANCE
############################################

resource "aws_instance" "this" {
  ami                         = data.aws_ami.bastion.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  key_name                    = var.ssh_key_name != "" ? var.ssh_key_name : null
  iam_instance_profile        = var.enable_ssm ? aws_iam_instance_profile.this[0].name : null
  associate_public_ip_address = var.associate_public_ip_address

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  user_data = var.user_data != "" ? var.user_data : file("${path.module}/user_data.sh")

  tags = merge({ Name = var.name }, var.tags)
}
