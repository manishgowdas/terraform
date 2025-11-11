########################################
# VALIDATE MULTI-AZ CONFIGURATION
########################################

locals {
  az_count = length(distinct([for s in var.db_subnets : s.az]))
}

resource "null_resource" "validate_multi_az" {
  count = var.db_multi_az && local.az_count < 2 ? 1 : 0

  provisioner "local-exec" {
    command = "echo '❌ ERROR: Multi-AZ requires at least 2 distinct AZs. Found only ${local.az_count}.' && exit 1"
  }
}

########################################
# CREATE RDS SUBNETS (PRIVATE)
########################################

resource "aws_subnet" "db_subnets" {
  for_each = {
    for idx, subnet in var.db_subnets : idx => subnet
  }

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env}-db-subnet-${each.key}"
  }
}

########################################
# ISOLATED ROUTE TABLE
########################################

resource "aws_route_table" "db_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.env}-db-rt"
  }
}

resource "aws_route_table_association" "db_rt_assoc" {
  for_each       = aws_subnet.db_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.db_rt.id
}

########################################
# DB SUBNET GROUP
########################################

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.env}-db-subnet-group"
  subnet_ids = [for s in aws_subnet.db_subnets : s.id]

  tags = {
    Name = "${var.env}-db-subnet-group"
  }
}

########################################
# SECURITY GROUP
########################################

resource "aws_security_group" "rds_sg" {
  name        = "${var.env}-rds-sg"
  description = "Allow DB access from application SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow app access to RDS"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-rds-sg"
  }
}

########################################
# RDS INSTANCE
########################################

resource "aws_db_instance" "rds" {
  depends_on = [null_resource.validate_multi_az]

  identifier              = "${var.env}-rds"
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  storage_type            = var.db_storage_type
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  publicly_accessible     = false
  multi_az                = var.db_multi_az
  skip_final_snapshot     = true
  deletion_protection     = var.db_deletion_protection
  storage_encrypted       = true
  port                    = var.db_port

  tags = {
    Name = "${var.env}-rds"
  }
}
