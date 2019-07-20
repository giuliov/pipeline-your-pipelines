resource "azurerm_virtual_machine" "linux_vm" {
  count                            = var.num_linux_hosts
  name                             = "${var.env_name}-linux${count.index + 1}-vm"
  location                         = azurerm_resource_group.pyp.location
  resource_group_name              = azurerm_resource_group.pyp.name
  network_interface_ids            = [azurerm_network_interface.vm_linux[count.index].id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true # CAVEAT: this is ok for demoing, a VERY BAD idea otherwise
  delete_data_disks_on_termination = true # CAVEAT: this is ok for demoing, a VERY BAD idea otherwise

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest" # CAVEAT: this is ok for demoing, for production specify a version
  }

  storage_os_disk {
    name              = "${var.env_name}-linux${count.index + 1}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.vm_disk_type
  }

  storage_data_disk {
    name              = "${var.env_name}-linux${count.index + 1}-datadisk"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
    managed_disk_type = var.vm_disk_type
  }

  os_profile {
    computer_name  = "${var.env_name}-linux${count.index + 1}"
    admin_username = var.vm_admin_username
    admin_password = random_string.vm_admin_password.result
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = local.tags
}

locals {
  ubuntu_setup = templatefile(
    "${path.module}/scripts/ubuntu-setup.sh.tpl",
    {
      azuredevops_url        = "${var.azuredevops_url}",
      azuredevops_pat        = "${var.azuredevops_pat}",
      azuredevops_pool_hosts = "${var.azuredevops_pool_hosts}"
    }
  )
  ubuntu_setup_base64 = base64encode(local.ubuntu_setup)
}


resource "azurerm_virtual_machine_extension" "linux_vm" {
  count                = var.num_linux_hosts
  name                 = "${var.env_name}-linux${count.index + 1}-vmext"
  location             = azurerm_resource_group.pyp.location
  resource_group_name  = azurerm_resource_group.pyp.name
  virtual_machine_name = azurerm_virtual_machine.linux_vm[count.index].name
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  protected_settings   = <<PROTECTED_SETTINGS
    {
      "script": "${local.ubuntu_setup_base64}"
    }
PROTECTED_SETTINGS
  tags = local.tags
}
