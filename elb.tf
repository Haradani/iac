resource "aws_elb" "elb-nodejs" {
  name = "${var.prefix}-elb"

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.elb_cert.arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances             = ["${aws_instance.nodejs.*.id}"]
  subnets               = ["${aws_subnet.public.*.id}"]

  security_groups       = ["${aws_security_group.elb_rules.id}"]

  tags = {
    Name = "${var.prefix}-elb"
  }
}

data "aws_acm_certificate" "elb_cert" {
  domain   = "*.iac.trainings.jambit.de"
  statuses = ["ISSUED"]
}
resource "aws_security_group" "elb_rules" {
  vpc_id = "${aws_vpc.vpc.id}"

  name        = "elb_rules"
  description = "Security group for the load balancer elb"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_route53_record" "elb-alias" {
  zone_id = "${data.aws_route53_zone.elb-zone.id}"
  name    = "${var.prefix}.iac.trainings.jambit.de"
  type    = "A"

  alias {
    name                   = "${aws_elb.elb-nodejs.dns_name}"
    zone_id                = "${aws_elb.elb-nodejs.zone_id}"
    evaluate_target_health = true
  }
}

 data "aws_route53_zone" "elb-zone" {
  name = "iac.trainings.jambit.de"
}