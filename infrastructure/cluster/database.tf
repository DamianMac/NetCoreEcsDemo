
resource "aws_db_subnet_group" "rdsmain_private" {
  name        = "rdsmain-private"
  description = "Private subnets for RDS instance"
  subnet_ids  = ["${aws_subnet.main.id}", "${aws_subnet.secondary.id}"]
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.6.6"
  instance_class       = "db.t2.micro"
  name                 = "stagingpostgres"
  username             = "admin_user"
  password             = "never_use_this_in_your_app"
  vpc_security_group_ids = ["${aws_security_group.allow_postgres.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.rdsmain_private.name}"
  publicly_accessible  = true
  copy_tags_to_snapshot = false

  
}