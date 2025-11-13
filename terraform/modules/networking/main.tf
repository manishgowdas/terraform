########################################
# NETWORKING MODULE (VPC, IGW, NAT, Routes)
########################################

########################################
# VPC
########################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = var.vpc_name })
}

########################################
# INTERNET GATEWAY (always create new)
########################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = var.igw_name != "" ? var.igw_name : "${var.vpc_name}-igw" }
  )
}

locals {
  igw_id = aws_internet_gateway.this.id
}
########################################
# PUBLIC SUBNETS
########################################
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name                                    = "${var.vpc_name}-public-${count.index}"
      "kubernetes.io/role/elb"               = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = var.enable_eks ? "shared" : null
    },
    var.extra_subnet_tags
  )
}

########################################
# PRIVATE SUBNETS
########################################
resource "aws_subnet" "private" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.vpc_name}-private-${count.index}"
      "kubernetes.io/role/internal-elb"           = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = var.enable_eks ? "shared" : null
    },
    var.extra_subnet_tags
  )
}

########################################
# NAT GATEWAY SETUP (Single shared NAT)
########################################

# Create a single Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.vpc_name}-nat-eip" })
}

# Create a single NAT Gateway in the first public subnet
resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.public[0].id
  allocation_id = aws_eip.nat.id
  depends_on    = [aws_internet_gateway.this]
  tags          = merge(var.tags, { Name = "${var.vpc_name}-nat" })
}

########################################
# PUBLIC ROUTE TABLE (Routes → IGW)
########################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.vpc_name}-public-rt" })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = local.igw_id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

########################################
# PRIVATE ROUTE TABLE (shared)
########################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.vpc_name}-private-rt" }
  )
}

########################################
# ROUTE: Private → NAT Gateway
########################################
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id   # use the first NAT gateway
}

########################################
# ASSOCIATE PRIVATE SUBNETS → PRIVATE RT
########################################
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

