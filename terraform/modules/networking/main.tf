########################################
# VPC MODULE
########################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

########################################
# INTERNET GATEWAY
########################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.igw_name != "" ? var.igw_name : "${var.vpc_name}-igw"
  }
}

########################################
# PUBLIC SUBNETS
########################################

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = element(var.availability_zones, index(var.public_subnets, each.value))
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.vpc_name}-public-${each.key}"
    },
    var.enable_eks ? {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/elb"                    = "1"
    } : {},
    var.extra_subnet_tags
  )
}

########################################
# PRIVATE SUBNETS
########################################

resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, index(var.private_subnets, each.value))

  tags = merge(
    {
      Name = "${var.vpc_name}-private-${each.key}"
    },
    var.enable_eks ? {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"           = "1"
    } : {},
    var.extra_subnet_tags
  )
}

########################################
# NAT GATEWAY
########################################

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public[*].id, 0)

  tags = {
    Name = var.nat_name != "" ? var.nat_name : "${var.vpc_name}-nat"
  }
}

########################################
# ROUTE TABLES
########################################

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = var.public_rt_name != "" ? var.public_rt_name : "${var.vpc_name}-public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = var.private_rt_name != "" ? var.private_rt_name : "${var.vpc_name}-private-rt"
  }
}

########################################
# ROUTE TABLE ASSOCIATIONS
########################################

resource "aws_route_table_association" "public" {
  for_each      = aws_subnet.public
  subnet_id     = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each      = aws_subnet.private
  subnet_id     = each.value.id
  route_table_id = aws_route_table.private.id
}
