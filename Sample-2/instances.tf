resource "aws_instance" "instance" {
  count                  = var.instanceCount
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.subnets.*.id[count.index % length(data.aws_availability_zones.azs.names)]
  vpc_security_group_ids = [aws_security_group.sgEgressInternet.id,
                            aws_security_group.sgIngressHTTP.id,
                            aws_security_group.sgIngressSSH.id]
  tags = {
    Name = "Node-${count.index + 1}"
  }
  user_data = file(var.user_data)

  provisioner "local-exec"{
        command = "aws ec2 wait instance-status-ok --instance-ids ${self.id}"
    }

  provisioner "local-exec" {
    command = <<-EOT
      cat <<EOF > "${self.tags.Name}.html"
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <title>Web Server</title>
        </head>
        <body>
          <p style="text-align: center;">
            <span style="color:DarkBlue"> <span style="font-size:20pt">
            You have landed on: ${self.tags.Name} <br /> <br />
            The IP of this webserver is: ${self.public_ip}
            </span></span>
          </p>
        </body>
      </html>
      EOF
    EOT
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "${self.tags.Name}.html"
    destination = "/tmp/index.html"
  }

  provisioner "local-exec"{
        command = "rm ${self.tags.Name}.html"
    }

  provisioner "remote-exec" {
  inline = ["sudo mv /tmp/index.html /var/www/html/"]
  }
}