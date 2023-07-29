output "instance_public_ip" {
  value = aws_instance.example_instance.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.example_db.endpoint
}
