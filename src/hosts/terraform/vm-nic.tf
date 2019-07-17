resource "azurerm_network_interface" "vm_windows" {
  count               = var.num_windows_hosts
  name                = "${var.env_name}-windows${count.index + 1}-nic"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name

  ip_configuration {
    name                          = "default-ip-config"
    subnet_id                     = azurerm_subnet.vm_windows_subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(azurerm_subnet.vm_windows_subnet.address_prefix, 5 + count.index)
    public_ip_address_id          = azurerm_public_ip.vm_windows[count.index].id
  }

  tags = local.tags
}

resource "azurerm_network_interface" "vm_linux" {
  count               = var.num_linux_hosts
  name                = "${var.env_name}-linux${count.index + 1}-nic"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name

  ip_configuration {
    name                          = "default-ip-config"
    subnet_id                     = azurerm_subnet.vm_linux_subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(azurerm_subnet.vm_linux_subnet.address_prefix, 5 + count.index)
    public_ip_address_id          = azurerm_public_ip.vm_linux[count.index].id
  }

  tags = local.tags
}
