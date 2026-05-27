output "endpoint" {
  description = "RDS endpoint (host:port)"
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "RDS hostname only (without port)"
  value       = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "database_name" {
  value = aws_db_instance.this.db_name
}

output "master_username" {
  value = aws_db_instance.this.username
}

output "master_user_secret_arn" {
  description = "ARN of Secrets Manager secret holding the master password"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.this.id
}
