########################################
# OUTPUTS
########################################
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.this.endpoint
}

output "rds_sg_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_sg.id
}

output "rds_subnet_ids" {
  description = "RDS private subnet IDs"
  value       = [for s in aws_subnet.db_subnets : s.id]
}

output "rds_route_table_id" {
  description = "RDS private route table ID"
  value       = aws_route_table.rds_private.id
}

