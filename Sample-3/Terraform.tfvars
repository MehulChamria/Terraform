client_name               = "ClientA"
parent_domain             = "Contoso.local"
location                  = "UK South"
virtualnetwork_cidr       = "10.0.1.0/24"
servers_subnet_cidr       = "10.0.1.0/24"
backup_timezone           = "GMT Standard Time"
admin_username            = "AdminUser"
adminuser_password_length = 20
dsrm_password_length      = 20

server_name = {
  "AD1"  = "AD1"
  "GW1"  = "GW1"
  "APP1" = "APP1"
  "DB1"  = "DB1"
}
server_size = {
  "AD1"  = "Standard_B2s"
  "GW1"  = "Standard_B2s"
  "APP1" = "Standard_B2s"
  "DB1"  = "Standard_B2s"
}
server_timezone = {
  "AD1"  = "GMT Standard Time"
  "GW1"  = "GMT Standard Time"
  "APP1" = "GMT Standard Time"
  "DB1"  = "GMT Standard Time"
}
server_ip_address = {
  "AD1"  = 11
  "GW1"  = 21
  "APP1" = 22
  "DB1"  = 23
}
server_sku = {
  "AD1"  = "2019-Datacenter"
  "GW1"  = "2019-Datacenter"
  "APP1" = "2019-Datacenter"
  "DB1"  = "Standard"
}