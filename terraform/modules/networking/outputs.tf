########################################
# NETWORKING MODULE OUTPUTS
########################################

# --- VPC ---
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.this.id
}

# --- Subnets ---
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

# --- NAT Gateway ---
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

# --- Internet Gateway ---
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}
# --- Elastic IPs for NAT ---
output "nat_eip_ids" {
  description = "List of Elastic IP allocation IDs for NAT gateways"
  value       = aws_eip.nat[*].id
}

# --- Route Tables ---
output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id
}

