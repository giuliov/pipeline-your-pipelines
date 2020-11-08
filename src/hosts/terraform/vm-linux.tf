resource "azurerm_linux_virtual_machine" "linux_vm" {
  count                 = var.num_linux_hosts
  name                  = "${var.env_name}-linux${count.index + 1}-vm"
  location              = azurerm_resource_group.pyp.location
  resource_group_name   = azurerm_resource_group.pyp.name
  network_interface_ids = [azurerm_network_interface.vm_linux[count.index].id]
  size                  = var.vm_size

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest" # CAVEAT: this is ok for demoing, for production specify a version
  }

  os_disk {
    name                 = "${var.env_name}-linux${count.index + 1}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.vm_disk_type
    disk_size_gb         = 200
  }

  computer_name                   = "${var.env_name}-linux${count.index + 1}"
  admin_username                  = var.vm_admin_username
  admin_password                  = random_string.vm_admin_password.result
  disable_password_authentication = false
  custom_data                     = local.ubuntu_setup_base64

  tags = local.tags
}

locals {
  ubuntu_setup = templatefile(
    "${path.module}/scripts/ubuntu-setup.sh.tpl",
    {
      azuredevops_url        = var.azuredevops_url,
      azuredevops_pat        = var.azuredevops_pat,
      azuredevops_pool_hosts = var.azuredevops_pool_hosts
    }
  )
  ubuntu_setup_lf     = replace(local.ubuntu_setup, "/\r\n/", "\n")
  ubuntu_setup_base64 = base64encode(local.ubuntu_setup_lf)
}
