data "aws_ami" "nodejs-ami" {
  most_recent = true
  owners = ["self", "099720109477"]

  filter {
    name = "name"
    values = ["*nodejs-rds-demo*"]
  }
  filter {
    name = "state"
    values = ["available"]
  }
}

resource "aws_instance" "nodejs" {

  count = 2

  ami = "${data.aws_ami.nodejs-ami.id}"
  instance_type = "t3.micro"

  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"

  key_name = "${var.prefix}"
  associate_public_ip_address = false
  vpc_security_group_ids = ["${aws_security_group.nodejs_rules.id}"]

  user_data_base64 = "${data.template_cloudinit_config.config.rendered}"

  tags {
    Name = "${var.prefix}"
  }
}

resource "aws_security_group" "nodejs_rules" {
  vpc_id = "${aws_vpc.vpc.id}"

  name        = "nodejs_rules"
  description = "Security group for the nodejs application"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  // dont use templating in cloud-config
  // ${data.template_file.node_config.rendered}

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = <<EOF
#cloud-config
write_files:
  - content: |
      DB_HOST = "${aws_db_instance.db-config.address}"
      DB_DB   = "${aws_db_instance.db-config.name}"
      DB_USER = "${aws_db_instance.db-config.username}"
      DB_PASS = "${aws_db_instance.db-config.password}"
    owner: root:root
    path: /etc/nodejs.env
    permissions: '0750'
runcmd:
  - [sudo, systemctl, enable, hello.service]
  - [sudo, systemctl, start, hello.service]
EOF
  }
}



// =========
// OLD STUFF
// =========

# resource "null_resource" "nodejs" {
#   // needed so the provision is connecting to all nodejs instances
#   // only possible without the load balancer
#   count = "${aws_instance.nodejs.count}"

#   triggers = {
#     instance_id = "${join(",", aws_instance.nodejs.*.id)}"
#   }

#   // define the connection type used by the provisioner
#   connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = "${file("~/.ssh/id_rsa")}"
#       timeout     = "90s"
#       agent       = "false"
#       host        = "${element(aws_instance.nodejs.*.public_ip, count.index)}"
#     }

#   provisioner "file" {
#     content     = "${data.template_file.node_config.rendered}"
#     destination = "/tmp/nodejs.env"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo mv /tmp/nodejs.env /etc/nodejs.env",
#     ]
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo systemctl enable hello.service",
#       "sudo systemctl start hello.service"
#     ]
#   }
# }

# data "aws_route53_zone" "nodejs-zone" {
#   name = "iac.trainings.jambit.de"
# }

# resource "aws_route53_record" "nodejs" {
#   count = "${aws_instance.nodejs.count}"
#   zone_id = "${data.aws_route53_zone.nodejs-zone.zone_id}"
#   name = "${var.prefix}-host-${count.index}"
#   type = "A"
#   ttl = "60"
#   records = ["${element(aws_instance.nodejs.*.public_ip, count.index)}"]
# }

# templating
# data "template_file" "node_config" {
#   template = "${file("${path.module}/conf/nodejs.env")}"
#   vars = {
#     DB_HOST = "${aws_db_instance.db-config.address}"
#     DB_DB   = "${aws_db_instance.db-config.name}"
#     DB_USER = "${aws_db_instance.db-config.username}"
#     DB_PASS = "${aws_db_instance.db-config.password}"
#   }
# }