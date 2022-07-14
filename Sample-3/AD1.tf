# Create a NIC for Domain Controller
resource "azurerm_network_interface" "AZ_RG1_AD1_NIC1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_AD1_NIC1"
  location            = var.location
  resource_group_name = azurerm_resource_group.AZ_RG1.name

  ip_configuration {
    name                          = "${azurerm_resource_group.AZ_RG1.name}_AD1_NIC1"
    subnet_id                     = azurerm_subnet.AZ_RG1_SN1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.servers_subnet_cidr, var.server_ip_address["AD1"])
  }
}

# Associate AD1 NIC with NSG1
resource "azurerm_network_interface_security_group_association" "AZ_RG1_AD1_NSA1" {
  network_interface_id      = azurerm_network_interface.AZ_RG1_AD1_NIC1.id
  network_security_group_id = azurerm_network_security_group.AZ_RG1_NSG1.id
}

# Create Windows Server Domain Controller
resource "azurerm_windows_virtual_machine" "AZ_RG1_AD1" {
  name                         = var.server_name["AD1"]
  location                     = var.location
  resource_group_name          = azurerm_resource_group.AZ_RG1.name
  size                         = var.server_size["AD1"]
  network_interface_ids        = [azurerm_network_interface.AZ_RG1_AD1_NIC1.id]
  provision_vm_agent           = true
  proximity_placement_group_id = azurerm_proximity_placement_group.AZ_RG1_PPG1.id

  computer_name            = var.server_name["AD1"]
  admin_username           = var.admin_username
  admin_password           = random_password.adminuser_password.result
  timezone                 = var.server_timezone["AD1"]
  enable_automatic_updates = "false"
  patch_mode               = "Manual"

  os_disk {
    name                 = "${azurerm_resource_group.AZ_RG1.name}_${var.server_name["AD1"]}_DISK_OS"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.server_sku["AD1"]
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.AZ_RG1_SA_BD1.primary_blob_endpoint
  }
}

# Custom Script Extension - Configure Domain Controller
resource "azurerm_virtual_machine_extension" "AZ_RG1_AD1_VME1" {
  name                 = "Customization"
  virtual_machine_id   = azurerm_windows_virtual_machine.AZ_RG1_AD1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}

resource "time_sleep" "AZ_RG1_AD1_TS1" {
  depends_on      = [azurerm_virtual_machine_extension.AZ_RG1_AD1_VME1]
  create_duration = "360s"
}