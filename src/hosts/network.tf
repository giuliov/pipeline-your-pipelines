resource "azurerm_virtual_network" "pyp" {
  name                = "${var.env_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name

  tags = local.tags
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "${var.env_name}-vm-subnet"
  resource_group_name  = azurerm_resource_group.pyp.name
  virtual_network_name = azurerm_virtual_network.pyp.name
  address_prefix       = cidrsubnet(azurerm_virtual_network.pyp.address_space.0, 8, 22)
}

resource "azurerm_public_ip" "vm" {
  count               = local.num_hosts
  name                = "${var.env_name}-${count.index}-publicip"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.env_name}-host-${count.index}"

  tags = local.tags
}
