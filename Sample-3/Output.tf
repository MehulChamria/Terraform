output "GW1PublicIP" {
  value = azurerm_public_ip.AZ_RG1_GW1_PIP1.ip_address
}

output "LocalAdminUsername" {
  value = var.admin_username
}

output "LocalAdminPassword" {
  value     = random_password.adminuser_password.result
  sensitive = "true"
}

output "DSRMPassword" {
  value     = random_password.dsrm_password.result
  sensitive = "true"
}