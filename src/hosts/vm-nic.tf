resource "azurerm_network_interface" "vm" {
  count               = local.num_hosts
  name                = "${var.env_name}-${count.index + 1}-nic"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name

  ip_configuration {
    name                          = "default-ip-config"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = cidrhost(azurerm_subnet.vm_subnet.address_prefix, 5 + count.index)
    public_ip_address_id          = azurerm_public_ip.vm[count.index].id
  }

  tags = local.tags
}