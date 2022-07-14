# Create Network Security Group to Access GW1
resource "azurerm_network_security_group" "AZ_RG1_GW1_NSG1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_GW1_NSG1"
  location            = var.location
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  security_rule {
    name                       = "AllowHTTPSInBound"
    description                = "InBound HTTPS Traffic for Website Access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDPInBound"
    description                = "InBound RDP Access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${local.outgoing_ip}/32"
    destination_address_prefix = "*"
  }
}

# Get a Static Public IP for GW1 Server
resource "azurerm_public_ip" "AZ_RG1_GW1_PIP1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_GW1_PIP1"
  location            = var.location
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  ip_version          = "IPv4"
  sku                 = "standard"
  sku_tier            = "Regional"
  allocation_method   = "Static"
  availability_zone   = "No-Zone"
}

# Create a NIC for GW1
resource "azurerm_network_interface" "AZ_RG1_GW1_NIC1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_GW1_NIC1"
  location            = var.location
  resource_group_name = azurerm_resource_group.AZ_RG1.name

  ip_configuration {
    name                          = "${azurerm_resource_group.AZ_RG1.name}_GW1_NIC1"
    subnet_id                     = azurerm_subnet.AZ_RG1_SN1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.servers_subnet_cidr, var.server_ip_address["GW1"])
    public_ip_address_id          = azurerm_public_ip.AZ_RG1_GW1_PIP1.id
  }
}

# Associate GW1 NIC with AZ_RG1_GW1_NSG1
resource "azurerm_network_interface_security_group_association" "AZ_RG1_GW1_NSA1" {
  network_interface_id      = azurerm_network_interface.AZ_RG1_GW1_NIC1.id
  network_security_group_id = azurerm_network_security_group.AZ_RG1_GW1_NSG1.id
}

# Create Windows Server - GW1
resource "azurerm_windows_virtual_machine" "AZ_RG1_GW1" {
  name                         = var.server_name["GW1"]
  location                     = var.location
  resource_group_name          = azurerm_resource_group.AZ_RG1.name
  size                         = var.server_size["GW1"]
  network_interface_ids        = [azurerm_network_interface.AZ_RG1_GW1_NIC1.id]
  provision_vm_agent           = true
  proximity_placement_group_id = azurerm_proximity_placement_group.AZ_RG1_PPG1.id

  computer_name            = var.server_name["GW1"]
  admin_username           = var.admin_username
  admin_password           = random_password.adminuser_password.result
  timezone                 = var.server_timezone["GW1"]
  enable_automatic_updates = "false"
  patch_mode               = "Manual"

  os_disk {
    name                 = "${azurerm_resource_group.AZ_RG1.name}_${var.server_name["GW1"]}_DISK_OS"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.server_sku["GW1"]
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.AZ_RG1_SA_BD1.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_extension" "AZ_RG1_GW1_JD1" {
  depends_on           = [time_sleep.AZ_RG1_AD1_TS1]
  name                 = "JoinDomainGW1"
  virtual_machine_id   = azurerm_windows_virtual_machine.AZ_RG1_GW1.id
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

# Custom Script Extension - Configure RDS Gateway Server
resource "azurerm_virtual_machine_extension" "AZ_RG1_GW1_VME1" {
  depends_on           = [azurerm_virtual_machine_extension.AZ_RG1_GW1_JD1]
  name                 = "CustomizationGW1"
  virtual_machine_id   = azurerm_windows_virtual_machine.AZ_RG1_GW1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command_gw1}\""
    }
SETTINGS
}