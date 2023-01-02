resource "aws_db_instance" "mysql" {
  instance_class = "db.t2.micro"
  identifier_prefix = "aleksej-db"
  engine = "mysql"
  allocated_storage = 10
  db_name = "base"
  username = "aleksej"
  password = "bebra1488"
  final_snapshot_identifier = "db-aleksej"
  skip_final_snapshot = true
}