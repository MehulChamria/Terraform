output "instance_IP" {
  value = aws_instance.instance.*.public_ips
}

output "loadBalancer_IP" {
  value = aws_lb.loadBalancer.dns_name
}