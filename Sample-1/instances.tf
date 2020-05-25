resource "aws_instance" "node" {
    count                  = var.instanceCount
    ami                    = var.amiID
    instance_type          = var.instanceType
    #subnet_id              = [for subnets in aws_subnet.subnets: subnets.id][count.index % length(data.aws_availability_zones.azs.names)]
    # subnet_id can also be populated using "for" command like above instead of "*"
    subnet_id              = aws_subnet.subnets.*.id[count.index % length(data.aws_availability_zones.azs.names)]
    key_name               = var.key_name
    
    vpc_security_group_ids = [aws_security_group.sgIngressRDP.id,
                              aws_security_group.sgIngressWinRM.id,
                              aws_security_group.sgEgressInternet.id,
                              aws_security_group.sgIngressWinRMHTTPS.id]
    
    get_password_data      = true
    user_data              = <<-EOF
        <Powershell>
        New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "WinRMHTTPSIn" -Profile Any -LocalPort 5986 -Protocol TCP -Verbose
        Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))
        </Powershell>
        EOF
    tags = {
        name = "Node-${count.index}"
    }

    provisioner "local-exec"{
        command = "aws ec2 wait instance-status-ok --instance-ids ${self.id}"
    }

    /* 
    # The code below was an easier way to create host file for ansible however, I noticed the HereDoc needs / if the string contains some special characters.
    # The password from AWS sometimes contained \ $ or ` that was ignored by below code.

    provisioner "local-exec" {
        command = <<-EOT
            cat <<EOF > ${self.tags.name}
            [AWS]
            ${self.public_ip}
            [AWS:vars]
            ansible_connection = winrm
            ansible_port = 5986
            ansible_user = Administrator
            ansible_password = ${rsadecrypt(self.password_data, file(var.private_key_path))}
            ansible_winrm_server_cert_validation = ignore
            EOF
        EOT
    }

    # Hence an alternate approach was to use the code below which worked perfectly.
    */

    provisioner "local-exec" {
        command = <<-EOT
        > ${self.tags.name}
	    echo "[AWS]" | tee -a ${self.tags.name}
        echo "${self.public_ip}" | tee -a ${self.tags.name}
        echo "[AWS:vars]" | tee -a ${self.tags.name}
        echo "ansible_connection = winrm" | tee -a ${self.tags.name}
        echo "ansible_port = 5986" | tee -a ${self.tags.name}
        echo "ansible_user = Administrator" | tee -a ${self.tags.name}
        echo "ansible_password = ${rsadecrypt(self.password_data, file(var.private_key_path))}" | tee -a ${self.tags.name}
        echo "ansible_winrm_server_cert_validation = ignore" | tee -a ${self.tags.name}
    	EOT
    }

    provisioner "local-exec"{
        command = "ansible-playbook -i ${self.tags.name} install_chrome.yml"
    }

    provisioner "local-exec"{
        command = "rm ${self.tags.name}"
    }

    /*
    I had a lot of trouble getting provisioners to work on Windows instances.
    The below worked and copied the folder but doesn't finishes even after the folder is completely copied and goes in an infinite loop.
    Not sure what went wrong! It would be good if it worked without too much effort.
    Ansible works flawlessly so getting the config management part was taken care of anyway.

    provisioner "file" {
        connection {
            type     = "winrm"
            port     = 5986
            https    = true
            insecure = true
            user     = "Administrator"
            password = rsadecrypt(self.password_data, file(var.private_key_path))
            host     = self.public_ip
            timeout  = "1m"
        }
        source      = "/home/user/Website_1"
        destination = "C:/Temp"
    }
    */
}