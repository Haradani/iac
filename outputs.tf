

output "public-ip" {
  value = "${aws_instance.demo.*.public_ip}"
}

output "name_servers" {
  value = "${aws_route53_record.host.*.records}"
}