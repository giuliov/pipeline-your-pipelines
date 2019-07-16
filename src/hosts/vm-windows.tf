resource "azurerm_virtual_machine" "windows_vm" {
  count                            = var.num_windows_hosts
  name                             = "${var.env_name}-win${count.index + 1}-vm"
  location                         = azurerm_resource_group.pyp.location
  resource_group_name              = azurerm_resource_group.pyp.name
  network_interface_ids            = [azurerm_network_interface.vm_windows[count.index].id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true # CAVEAT: this is ok for demoing, a VERY BAD idea otherwise
  delete_data_disks_on_termination = true # CAVEAT: this is ok for demoing, a VERY BAD idea otherwise

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-smalldisk"
    version   = "latest" # CAVEAT: this is ok for demoing, for production specify a version
  }

  storage_os_disk {
    name              = "${var.env_name}-win${count.index + 1}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.vm_disk_type
  }

  storage_data_disk {
    name              = "${var.env_name}-win${count.index + 1}-datadisk"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "50"
    managed_disk_type = var.vm_disk_type
  }

  os_profile {
    computer_name  = "${upper(local.env_name_nosymbols)}WIN${count.index + 1}" # 16 chars
    admin_username = var.vm_admin_username
    admin_password = random_string.vm_admin_password.result
    # Careful to stay within 64 KB limit for the custom data block
    custom_data    = "Param($ComputerName = \"${upper(local.env_name_nosymbols)}WIN${count.index + 1}\") ${file("${path.module}/scripts/winrm.ps1")}"
  }

  os_profile_secrets {
    source_vault_id = azurerm_key_vault.pyp.id

    vault_certificates {
      certificate_url   = azurerm_key_vault_certificate.win_vm[count.index].secret_id
      certificate_store = "My"
    }
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false

    winrm {
      protocol        = "HTTPS"
      certificate_url = azurerm_key_vault_certificate.win_vm[count.index].secret_id
    }

/*
    # Auto-Login's required to configure WinRM
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${random_string.vm_admin_password.result}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.vm_admin_username}</Username></AutoLogon>"
    }

    # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = file("${path.module}/scripts/FirstLogonCommands.xml")
    }
*/
  }

  provisioner "file" {
    source      = "${path.module}/scripts/windows-setup.ps1"
    destination = "C:\\terraform\\windows-setup.ps1"

    connection {
      type     = "winrm"
      host     = azurerm_public_ip.vm_windows[count.index].fqdn
      user     = var.vm_admin_username
      password = random_string.vm_admin_password.result
      port     = 5986
      https    = true
      timeout  = "10m"

      # NOTE: if you're using a real certificate, rather than a self-signed one, you'll want this set to `false`/to remove this.
      insecure = true
    }
  }

  provisioner "remote-exec" {
    inline = [
      "C:\\terraform\\windows-setup.ps1 -AZP_URL ${var.azuredevops_url} -AZP_TOKEN ${var.azuredevops_pat} -AZP_POOL ${var.azuredevops_pool_hosts}",
    ]

    connection {
      type     = "winrm"
      host     = azurerm_public_ip.vm_windows[count.index].fqdn
      user     = var.vm_admin_username
      password = random_string.vm_admin_password.result
      port     = 5986
      https    = true
      timeout  = "10m"

      # NOTE: if you're using a real certificate, rather than a self-signed one, you'll want this set to `false`/to remove this.
      insecure = true
    }
  }

  tags = local.tags
}


resource "azurerm_key_vault_certificate" "win_vm" {
  count     = var.num_windows_hosts
  name      = "${var.env_name}-win${count.index + 1}-cert"
  vault_uri = azurerm_key_vault.pyp.vault_uri

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      # MUST match azurerm_virtual_machine.os_profile.computer_name
      subject            = "CN=${upper(local.env_name_nosymbols)}WIN${count.index + 1}"
      validity_in_months = 12
    }
  }
}