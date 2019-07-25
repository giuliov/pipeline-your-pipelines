resource "azurerm_virtual_network" "pyp" {
  name                = "${var.env_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name

  tags = local.tags
}

resource "azurerm_subnet" "vm_windows_subnet" {
  name                 = "${var.env_name}-win-vm-subnet"
  resource_group_name  = azurerm_resource_group.pyp.name
  virtual_network_name = azurerm_virtual_network.pyp.name
  address_prefix       = cidrsubnet(azurerm_virtual_network.pyp.address_space.0, 8, 1)
  # Remove after upgrading AzureRM Provider 2.0 (see Issue #3289)
  network_security_group_id = azurerm_network_security_group.vm_windows.id
}

resource "azurerm_subnet" "vm_linux_subnet" {
  name                 = "${var.env_name}-linux-vm-subnet"
  resource_group_name  = azurerm_resource_group.pyp.name
  virtual_network_name = azurerm_virtual_network.pyp.name
  address_prefix       = cidrsubnet(azurerm_virtual_network.pyp.address_space.0, 8, 2)
  # Remove after upgrading AzureRM Provider 2.0 (see Issue #3289)
  network_security_group_id = azurerm_network_security_group.vm_linux.id
}

resource "azurerm_public_ip" "vm_windows" {
  count               = var.vm_public_access ? var.num_windows_hosts : 0
  name                = "${var.env_name}-winhost${count.index + 1}-publicip"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.env_name}-winhost${count.index + 1}"

  tags = local.tags
}

resource "azurerm_public_ip" "vm_linux" {
  count               = var.vm_public_access ? var.num_linux_hosts : 0
  name                = "${var.env_name}-linuxhost${count.index + 1}-publicip"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.env_name}-linuxhost${count.index + 1}"

  tags = local.tags
}