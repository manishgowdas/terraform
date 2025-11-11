output "instance_id" {
  description = "Bastion EC2 instance ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP of Bastion (if applicable)"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP of Bastion"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.this.id
}
