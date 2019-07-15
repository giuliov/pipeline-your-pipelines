resource "azurerm_virtual_machine" "linux_vm" {
  count                            = var.num_linux_hosts
  name                             = "${var.env_name}-linux${count.index + 1}-vm"
  location                         = azurerm_resource_group.pyp.location
  resource_group_name              = azurerm_resource_group.pyp.name
  network_interface_ids            = [azurerm_network_interface.vm_linux[count.index].id]
  vm_size                          = "Standard_B2s"
  delete_os_disk_on_termination    = true # CAVEAT: this is ok for demoing, a VERY BAD idea otherwise
  delete_data_disks_on_termination = true # CAVEAT: this is ok for demoing, a VERY BAD idea otherwise

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest" # CAVEAT: this is ok for demoing, for production specify a version
  }

  storage_os_disk {
    name          = "${var.env_name}-linux${count.index + 1}-osdisk"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "${var.env_name}-linux${count.index + 1}-datadisk"
    create_option = "Empty"
    lun           = 0
    disk_size_gb  = "30"
  }

  os_profile {
    computer_name  = "${var.env_name}-linux${count.index + 1}"
    admin_username = var.vm_admin_username
    admin_password = random_string.vm_admin_password.result
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "file" {
    source      = "${path.module}/scripts/ubuntu-setup.sh"
    destination = "/tmp/ubuntu-setup.sh"
    connection {
      type     = "ssh"
      host     = azurerm_public_ip.vm_linux[count.index].fqdn
      user     = var.vm_admin_username
      password = random_string.vm_admin_password.result
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ubuntu-setup.sh",
      "/tmp/ubuntu-setup.sh ${var.azuredevops_url} ${var.azuredevops_pat} ${var.azuredevops_pool_hosts}",
    ]
    connection {
      type     = "ssh"
      host     = azurerm_public_ip.vm_linux[count.index].fqdn
      user     = var.vm_admin_username
      password = random_string.vm_admin_password.result
    }
  }

  tags = local.tags
}