resource "azurerm_virtual_network" "pyp" {
  name                = "${var.env_name}-vnet"
  address_space       = ["10.3.0.0/16"]
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name

  tags = local.tags
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.env_name}-aks-subnet"
  resource_group_name  = azurerm_resource_group.pyp.name
  virtual_network_name = azurerm_virtual_network.pyp.name
  address_prefix       = cidrsubnet(azurerm_virtual_network.pyp.address_space.0, 8, 3)
  # this field is deprecated and will be removed in 2.0 - but is required until then
  route_table_id = azurerm_route_table.aks.id
}

resource "azurerm_route_table" "aks" {
  name                = "${var.env_name}-routetable"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name

  route {
    name                   = "default"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}

resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.aks.id
}
