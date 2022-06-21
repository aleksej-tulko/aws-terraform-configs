output "address" {
  value = aws_db_instance.mysql.address
  description = "Address of the DB"
}
output "port" {
  value = aws_db_instance.mysql.port
  description = "Port of the DB"
}