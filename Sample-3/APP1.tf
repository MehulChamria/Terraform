# Create a NIC for APP1
resource "azurerm_network_interface" "AZ_RG1_APP1_NIC1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_APP1_NIC1"
  location            = var.location
  resource_group_name = azurerm_resource_group.AZ_RG1.name

  ip_configuration {
    name                          = "${azurerm_resource_group.AZ_RG1.name}_APP1_NIC1"
    subnet_id                     = azurerm_subnet.AZ_RG1_SN1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.servers_subnet_cidr, var.server_ip_address["APP1"])
  }
}

# Associate APP1 NIC with NSG1
resource "azurerm_network_interface_security_group_association" "AZ_RG1_APP1_NSA1" {
  network_interface_id      = azurerm_network_interface.AZ_RG1_APP1_NIC1.id
  network_security_group_id = azurerm_network_security_group.AZ_RG1_NSG1.id
}

# Create Windows Server - APP1
resource "azurerm_windows_virtual_machine" "AZ_RG1_APP1" {
  name                         = var.server_name["APP1"]
  location                     = var.location
  resource_group_name          = azurerm_resource_group.AZ_RG1.name
  size                         = var.server_size["APP1"]
  network_interface_ids        = [azurerm_network_interface.AZ_RG1_APP1_NIC1.id]
  provision_vm_agent           = true
  proximity_placement_group_id = azurerm_proximity_placement_group.AZ_RG1_PPG1.id

  computer_name            = var.server_name["APP1"]
  admin_username           = var.admin_username
  admin_password           = random_password.adminuser_password.result
  timezone                 = var.server_timezone["APP1"]
  enable_automatic_updates = "false"
  patch_mode               = "Manual"

  os_disk {
    name                 = "${azurerm_resource_group.AZ_RG1.name}_${var.server_name["APP1"]}_DISK_OS"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.server_sku["APP1"]
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.AZ_RG1_SA_BD1.primary_blob_endpoint
  }
}

resource "azurerm_managed_disk" "AZ_RG1_APP1_DD1" {
  name                 = "${azurerm_resource_group.AZ_RG1.name}_${var.server_name["APP1"]}_DISK_USERFILES"
  location             = azurerm_resource_group.AZ_RG1.location
  resource_group_name  = azurerm_resource_group.AZ_RG1.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "AZ_RG1_APP1_DDA1" {
  managed_disk_id    = azurerm_managed_disk.AZ_RG1_APP1_DD1.id
  virtual_machine_id = azurerm_windows_virtual_machine.AZ_RG1_APP1.id
  lun                = "0"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "AZ_RG1_APP1_JD1" {
  depends_on           = [time_sleep.AZ_RG1_AD1_TS1]
  name                 = "JoinDomainAPP1"
  virtual_machine_id   = azurerm_windows_virtual_machine.AZ_RG1_APP1.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  # NOTE: the `OUPath` field is intentionally blank, to put it in the Computers OU. User had to be used in format User@domain else it failed with domain/user format.
  settings = <<SETTINGS
    {
        "Name": "${var.client_name}.${var.parent_domain}",
        "OUPath": "",
        "User": "${var.admin_username}@${var.client_name}.${var.parent_domain}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${random_password.adminuser_password.result}"
    }
SETTINGS
}