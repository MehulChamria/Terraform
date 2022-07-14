# Create a NIC for DB1
resource "azurerm_network_interface" "AZ_RG1_DB1_NIC1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_DB1_NIC1"
  location            = var.location
  resource_group_name = azurerm_resource_group.AZ_RG1.name

  ip_configuration {
    name                          = "${azurerm_resource_group.AZ_RG1.name}_DB1_NIC1"
    subnet_id                     = azurerm_subnet.AZ_RG1_SN1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.servers_subnet_cidr, var.server_ip_address["DB1"])
  }
}

# Associate DB1 NIC with NSG01
resource "azurerm_network_interface_security_group_association" "AZ_RG1_DB1_NSA1" {
  network_interface_id      = azurerm_network_interface.AZ_RG1_DB1_NIC1.id
  network_security_group_id = azurerm_network_security_group.AZ_RG1_NSG1.id
}

# Create Windows Server - DB1
resource "azurerm_windows_virtual_machine" "AZ_RG1_DB1" {
  name                         = var.server_name["DB1"]
  location                     = var.location
  resource_group_name          = azurerm_resource_group.AZ_RG1.name
  size                         = var.server_size["DB1"]
  network_interface_ids        = [azurerm_network_interface.AZ_RG1_DB1_NIC1.id]
  provision_vm_agent           = true
  proximity_placement_group_id = azurerm_proximity_placement_group.AZ_RG1_PPG1.id

  computer_name            = var.server_name["DB1"]
  admin_username           = var.admin_username
  admin_password           = random_password.adminuser_password.result
  timezone                 = var.server_timezone["DB1"]
  enable_automatic_updates = "false"
  patch_mode               = "Manual"

  os_disk {
    name                 = "${azurerm_resource_group.AZ_RG1.name}_${var.server_name["DB1"]}_DISK_OS"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2017-ws2019"
    sku       = var.server_sku["DB1"]
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.AZ_RG1_SA_BD1.primary_blob_endpoint
  }
}

resource "azurerm_managed_disk" "AZ_RG1_DB1_DD1" {
  name                 = "${azurerm_resource_group.AZ_RG1.name}_${azurerm_windows_virtual_machine.AZ_RG1_DB1.name}_DISK_SQLDATA"
  location             = var.location
  resource_group_name  = azurerm_resource_group.AZ_RG1.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "AZ_RG1_DB1_DDA1" {
  managed_disk_id    = azurerm_managed_disk.AZ_RG1_DB1_DD1.id
  virtual_machine_id = azurerm_windows_virtual_machine.AZ_RG1_DB1.id
  lun                = "0"
  caching            = "ReadOnly"
}

resource "azurerm_managed_disk" "AZ_RG1_DB1_LD1" {
  name                 = "${azurerm_resource_group.AZ_RG1.name}_${azurerm_windows_virtual_machine.AZ_RG1_DB1.name}_DISK_SQLLOG"
  location             = var.location
  resource_group_name  = azurerm_resource_group.AZ_RG1.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "AZ_RG1_DB1_LDA1" {
  managed_disk_id    = azurerm_managed_disk.AZ_RG1_DB1_LD1.id
  virtual_machine_id = azurerm_windows_virtual_machine.AZ_RG1_DB1.id
  lun                = "1"
  caching            = "None"
}

resource "azurerm_mssql_virtual_machine" "AZ_RG1_DB1_MSSQL1" {
  depends_on = [azurerm_virtual_machine_data_disk_attachment.AZ_RG1_DB1_LDA1,
  azurerm_virtual_machine_data_disk_attachment.AZ_RG1_DB1_DDA1]
  virtual_machine_id = azurerm_windows_virtual_machine.AZ_RG1_DB1.id
  sql_license_type   = "PAYG"
  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "OLTP"

    data_settings {
      default_file_path = "S:\\DATA"
      luns              = [0]
    }
    log_settings {
      default_file_path = "T:\\LOG"
      luns              = [1]
    }
    temp_db_settings {
      default_file_path = "S:\\TEMPDB"
      luns              = [0]
    }
  }
}

resource "azurerm_virtual_machine_extension" "AZ_RG1_DB1_JD1" {
  depends_on = [time_sleep.AZ_RG1_AD1_TS1,
  azurerm_mssql_virtual_machine.AZ_RG1_DB1_MSSQL1]
  name                 = "JoinDomainDB1"
  virtual_machine_id   = azurerm_windows_virtual_machine.AZ_RG1_DB1.id
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