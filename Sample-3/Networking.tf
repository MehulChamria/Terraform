# Create a virtual network within the resource group
resource "azurerm_virtual_network" "AZ_RG1_VN1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_VNET1"
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  location            = azurerm_resource_group.AZ_RG1.location
  address_space       = [var.virtualnetwork_cidr]
}

# Create servers subnet within the virtual network
resource "azurerm_subnet" "AZ_RG1_SN1" {
  name                 = "${azurerm_resource_group.AZ_RG1.name}_SNET1"
  resource_group_name  = azurerm_resource_group.AZ_RG1.name
  virtual_network_name = azurerm_virtual_network.AZ_RG1_VN1.name
  address_prefixes     = [var.servers_subnet_cidr]
}

# Create Network Security Group for the Subnet
resource "azurerm_network_security_group" "AZ_RG1_NSG1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_NSG1"
  location            = azurerm_resource_group.AZ_RG1.location
  resource_group_name = azurerm_resource_group.AZ_RG1.name
}

#Create a proximity placement group
resource "azurerm_proximity_placement_group" "AZ_RG1_PPG1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_PPG1"
  location            = azurerm_resource_group.AZ_RG1.location
  resource_group_name = azurerm_resource_group.AZ_RG1.name
}

# Create a NAT Gateway
resource "azurerm_nat_gateway" "AZ_RG1_NAT1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_NAT1"
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  location            = azurerm_resource_group.AZ_RG1.location
}

# Get a Static Public IP for NAT Gateway
resource "azurerm_public_ip" "AZ_RG1_NAT1_PIP1" {
  name                = "${azurerm_resource_group.AZ_RG1.name}_NAT1_PIP1"
  location            = azurerm_resource_group.AZ_RG1.location
  resource_group_name = azurerm_resource_group.AZ_RG1.name
  ip_version          = "IPv4"
  sku                 = "standard"
  sku_tier            = "Regional"
  allocation_method   = "Static"
  availability_zone   = "No-Zone"
}

# Associate NAT Gateway with Public IP for NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "AZ_RG1_NAT1_PIA1" {
  nat_gateway_id       = azurerm_nat_gateway.AZ_RG1_NAT1.id
  public_ip_address_id = azurerm_public_ip.AZ_RG1_NAT1_PIP1.id
}

# Associate NAT Gateway with servers subnet
resource "azurerm_subnet_nat_gateway_association" "AZ_RG1_NAT1_SNA1" {
  subnet_id      = azurerm_subnet.AZ_RG1_SN1.id
  nat_gateway_id = azurerm_nat_gateway.AZ_RG1_NAT1.id
}

# Associate DNS server of AD1 and AD2 with Virtual Network
resource "azurerm_virtual_network_dns_servers" "AZ_RG1_NDS1" {
  virtual_network_id = azurerm_virtual_network.AZ_RG1_VN1.id
  dns_servers        = [azurerm_network_interface.AZ_RG1_AD1_NIC1.private_ip_address]
}