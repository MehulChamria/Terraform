resource "azurerm_recovery_services_vault" "AZ_RG1_ARSV1" {
  name                = upper("${azurerm_resource_group.AZ_RG1.name}-RECOVERY-VAULT")
  location            = var.location
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  sku                 = "Standard"
  storage_mode_type   = "LocallyRedundant"
}

resource "azurerm_backup_policy_vm" "AZ_RG1_DVP1" {
  name                = "${var.client_name}VMPolicy"
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  recovery_vault_name = azurerm_recovery_services_vault.AZ_RG1_ARSV1.name

  timezone                       = var.backup_timezone
  instant_restore_retention_days = 2

  backup {
    frequency = "Daily"
    time      = "02:00"
  }

  retention_daily {
    count = 30
  }
}

resource "azurerm_backup_protected_vm" "AZ_RG1_AD1_BK1" {
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  recovery_vault_name = azurerm_recovery_services_vault.AZ_RG1_ARSV1.name
  source_vm_id        = azurerm_windows_virtual_machine.AZ_RG1_AD1.id
  backup_policy_id    = azurerm_backup_policy_vm.AZ_RG1_DVP1.id
}

resource "azurerm_backup_protected_vm" "AZ_RG1_APP1_BK1" {
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  recovery_vault_name = azurerm_recovery_services_vault.AZ_RG1_ARSV1.name
  source_vm_id        = azurerm_windows_virtual_machine.AZ_RG1_APP1.id
  backup_policy_id    = azurerm_backup_policy_vm.AZ_RG1_DVP1.id
}

resource "azurerm_backup_protected_vm" "AZ_RG1_DB1_BK1" {
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  recovery_vault_name = azurerm_recovery_services_vault.AZ_RG1_ARSV1.name
  source_vm_id        = azurerm_windows_virtual_machine.AZ_RG1_DB1.id
  backup_policy_id    = azurerm_backup_policy_vm.AZ_RG1_DVP1.id
}

resource "azurerm_backup_protected_vm" "AZ_RG1_GW1_BK1" {
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  recovery_vault_name = azurerm_recovery_services_vault.AZ_RG1_ARSV1.name
  source_vm_id        = azurerm_windows_virtual_machine.AZ_RG1_GW1.id
  backup_policy_id    = azurerm_backup_policy_vm.AZ_RG1_DVP1.id
}