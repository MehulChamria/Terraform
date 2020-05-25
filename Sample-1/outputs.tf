output "instance_IP" {
    value = [
        aws_instance.node.*.public_ip
        ]
}

output "password_decrypted" {
    value = [
        for instance in aws_instance.node: rsadecrypt(instance.password_data, file(var.private_key_path))
        ]
}