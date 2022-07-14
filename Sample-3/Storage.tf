resource "azurerm_storage_account" "AZ_RG1_SA_BD1" {
  name                     = lower("${azurerm_resource_group.AZ_RG1.name}bootdiagsa1")
  resource_group_name      = azurerm_resource_group.AZ_RG1.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}