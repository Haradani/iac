

data "aws_ami" "demo-ami" {
  most_recent = true
  owners = ["self", "099720109477"]

  filter {
    name = "name"
    # values = ["*ubuntu-bionic-18.04-amd64-server-*"]
    values = ["nodejs-demo-*"]
  }
  filter {
    name = "state"
    values = ["available"]
  }
}
data "aws_route53_zone" "demo-zone" {
  name = "iac.trainings.jambit.de"
}

# resource "aws_route53_record" "www" {
#   zone_id = "${data.aws_route53_zone.demo-zone.zone_id}"
#   name    = "www.${var.prefix}.${data.aws_route53_zone.demo-zone.name}"
#   type    = "A"
#   ttl     = "60"
#   records = [
#     "${aws_instance.demo.*.public_ip}"
#   ]
# }

resource "aws_route53_record" "host" {
  count = "${length(aws_instance.demo.*.id)}"
  zone_id = "${data.aws_route53_zone.demo-zone.zone_id}"
  name = "${var.prefix}.host-${count.index}"
  type = "A"
  ttl = "60"
  records = ["${element(aws_instance.demo.*.public_ip, count.index)}"]
}


resource "aws_instance" "demo" {

  count = 2

  ami = "${data.aws_ami.demo-ami.id}"
  instance_type = "t3.micro"

  associate_public_ip_address = true
  subnet_id = "${data.aws_subnet.subnet.id}"

  key_name = "${var.prefix}"
  vpc_security_group_ids = [
    "${aws_security_group.demo.id}"
  ]

  user_data = <<EOT
#cloud-config
preserve_hostname: false
manage_etc_hosts: true
hostname: demo-${var.prefix}${count.index}
fqdn: demo-${var.prefix}${count.index}
EOT

  tags {
    Name = "${var.prefix}"
  }
}

resource "aws_security_group" "demo" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.prefix}"
  }


}