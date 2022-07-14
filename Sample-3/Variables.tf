# Dynamically retrieve our public outgoing IP
data "http" "outgoing_ip" {
  url = "https://ifconfig.me"
}

locals {
  outgoing_ip = chomp(data.http.outgoing_ip.body)
}

locals {
  install_adds           = "Install-Windowsfeature -Name AD-Domain-Services -IncludeManagementTools"
  install_adcs           = "Install-Windowsfeature -Name AD-Certificate,RSAT-ADCS-Mgmt,RSAT-ADCS,ADLDS"
  install_rds            = "Install-Windowsfeature -Name NPAS,Remote-Desktop-Services,RDS-Connection-Broker,RDS-Gateway,RDS-Web-Access,RSAT-RDS-Tools,RSAT-NPAS"
  import_module          = "Import-Module ADDSDeployment"
  password_command       = "$password = ConvertTo-SecureString ${random_password.dsrm_password.result} -AsPlainText -Force"
  configure_ad           = "Install-ADDSForest -CreateDnsDelegation:$false -DomainName ${var.client_name}.${var.parent_domain} -DomainNetbiosName ${var.client_name} -DomainMode WinThreshold -ForestMode WinThreshold -InstallDns:$true -SafeModeAdministratorPassword $password -NoRebootOnCompletion:$false -Force:$true"
  shutdown_command       = "shutdown -r -t 0"
  exit_code_hack         = "exit 0"
  powershell_command     = "${local.install_adds}; ${local.import_module}; ${local.password_command}; ${local.configure_ad}; ${local.shutdown_command}; ${local.exit_code_hack}"
  powershell_command_gw1 = local.install_rds
  powershell_command_gw2 = local.install_rds
}

# Directory Services Restore Mode password
resource "random_password" "dsrm_password" {
  length           = var.dsrm_password_length
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!%*@[]" # Custom list of special characters to use. Using the character '&' for SafeMode password results in error since its a reserved character so don't use it in this list. Symbols { and } has some issues as well.
}

# Domain Controller AdminUser password
resource "random_password" "adminuser_password" {
  length           = var.adminuser_password_length
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!%*@[]{}"
}

variable "client_name" {
  type        = string
  description = "Client Name"
}

variable "parent_domain" {
  type        = string
  description = "Parent Domain Name"
}

variable "location" {
  type        = string
  description = "Resource Group Location"
}

variable "virtualnetwork_cidr" {
  type        = string
  description = "CIDR Range for VNET"
}

variable "servers_subnet_cidr" {
  type        = string
  description = "Subnet range"
}

variable "server_name" {
  type        = map(any)
  description = "Name of the server/s"
}

variable "server_size" {
  type        = map(any)
  description = "Size of the server/s"
}

variable "server_sku" {
  type        = map(any)
  description = "SKU of the server/s"
}

variable "server_ip_address" {
  type        = map(any)
  description = "IP address for the server"
}

variable "server_timezone" {
  type        = map(any)
  description = "Time Zone of the server/s"
}

variable "admin_username" {
  type        = string
  description = "Default Admin Username"
}

variable "dsrm_password_length" {
  type        = number
  description = "Character length of the password"
}

variable "adminuser_password_length" {
  type        = number
  description = "Character length of the password"
}

variable "backup_timezone" {
  type        = string
  description = "Timezone for Backups"
}