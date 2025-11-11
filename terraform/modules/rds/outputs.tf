########################################
# OUTPUTS
########################################

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.rds.endpoint
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

output "rds_subnet_ids" {
  description = "List of RDS private subnet IDs"
  value       = [for s in aws_subnet.db_subnets : s.id]
}

output "rds_subnet_group" {
  description = "Name of the RDS subnet group"
  value       = aws_db_subnet_group.db_subnet_group.name
}
