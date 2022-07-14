# Create a resource group
resource "azurerm_resource_group" "AZ_RG1" {
  name     = upper(var.client_name)
  location = var.location
}