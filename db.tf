resource "aws_db_instance" "db-config" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.small"
  name                 = "${var.prefix}"
  username             = "${var.prefix}"
  password             = "${var.prefix}"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  vpc_security_group_ids = ["${aws_security_group.rds_rules.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  identifier = "${var.prefix}"

  tags {
      Name = "${var.prefix}"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.prefix}-main"
  subnet_ids = ["${aws_subnet.private.*.id}"]

  tags = {
    Name = "${var.prefix} - My DB subnet group"
  }
}

resource "aws_security_group" "rds_rules" {
  vpc_id = "${aws_vpc.vpc.id}"

  name        = "rds_rules"
  description = "Enable Port 3306 for mysql db"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}