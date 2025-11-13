########################################
# RDS MODULE - ISOLATED SUBNETS + ROUTE TABLE
########################################

########################################
# LOCALS
########################################
locals {
  db_subnet_group_name = "${var.env}-rds-subnet-group"
  db_rt_name           = "${var.env}-rds-private-rt"
}

########################################
# ISOLATED RDS SUBNETS
########################################
resource "aws_subnet" "db_subnets" {
  for_each = { for s in var.db_subnets : s.az => s }

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = "${var.env}-rds-subnet-${each.key}"
      Role = "rds-private"
    }
  )
}

########################################
# DEDICATED ROUTE TABLE
########################################
resource "aws_route_table" "rds_private" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = local.db_rt_name })
}

# No outbound Internet route (RDS should stay isolated)
# Optionally add a NAT route if absolutely needed:
# resource "aws_route" "rds_nat_access" {
#   route_table_id         = aws_route_table.rds_private.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = var.nat_gateway_id
# }

########################################
# ROUTE TABLE ASSOCIATIONS
########################################
resource "aws_route_table_association" "rds_assoc" {
  for_each      = aws_subnet.db_subnets
  subnet_id     = each.value.id
  route_table_id = aws_route_table.rds_private.id
}

########################################
# RDS SUBNET GROUP
########################################
resource "aws_db_subnet_group" "this" {
  name       = local.db_subnet_group_name
  subnet_ids = [for s in aws_subnet.db_subnets : s.id]
  tags       = merge(var.tags, { Name = local.db_subnet_group_name })
}

########################################
# SECURITY GROUP
########################################
resource "aws_security_group" "rds_sg" {
  name        = "${var.env}-rds-sg"
  description = "Security group for RDS access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow access from app SG"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = var.app_sg_id != "" ? [var.app_sg_id] : []
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.env}-rds-sg" })
}

########################################
# RDS INSTANCE
########################################
resource "aws_db_instance" "this" {
  identifier             = "${var.env}-rds-instance"
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = var.db_storage_type
  username               = var.db_username
  password               = var.db_password
  port                   = var.db_port
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az               = var.db_multi_az
  deletion_protection    = var.db_deletion_protection
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = merge(var.tags, { Name = "${var.env}-rds" })
}


