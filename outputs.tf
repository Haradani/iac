# output "public-ip" {
#   value = "${aws_instance.nodejs.*.public_ip}"
# }

output "elb-dns" {
  value = "${aws_elb.elb-nodejs.dns_name}"
}