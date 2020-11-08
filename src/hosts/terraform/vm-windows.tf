resource "azurerm_windows_virtual_machine" "windows_vm" {
  count                 = var.num_windows_hosts
  name                  = "${var.env_name}-win${count.index + 1}-vm"
  location              = azurerm_resource_group.pyp.location
  resource_group_name   = azurerm_resource_group.pyp.name
  network_interface_ids = [azurerm_network_interface.vm_windows[count.index].id]
  size                  = var.vm_size

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-with-Containers-smalldisk" # 2019-Datacenter-Core-with-Containers-smalldisk
    version   = "latest"                                    # CAVEAT: this is ok for demoing, for production specify a version
  }

  os_disk {
    name                 = "${var.env_name}-win${count.index + 1}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.vm_disk_type
  }

  computer_name  = substr(upper("w${count.index + 1}${var.env_name}"), 0, 15) # Trim to stay within 16 chars limit
  admin_username = var.vm_admin_username
  admin_password = random_string.vm_admin_password.result
  # CAVEAT: Careful to stay within 64 KB limit for the custom data block
  custom_data = base64encode("Param($AZP_URL='${var.azuredevops_url}',$AZP_TOKEN='${var.azuredevops_pat}',$AZP_POOL='${var.azuredevops_pool_hosts}') ${file("${path.module}/scripts/windows-setup.ps1")}")

  secret {
    key_vault_id = azurerm_key_vault.pyp.id

    certificate {
      url   = azurerm_key_vault_certificate.windows_vm[count.index].secret_id
      store = "My"
    }
  }

  provision_vm_agent = true

  # Auto-Login's required to configure machine
  additional_unattend_content {
    setting = "AutoLogon"
    content = "<AutoLogon><Password><Value>${random_string.vm_admin_password.result}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.vm_admin_username}</Username></AutoLogon>"
  }

  additional_unattend_content {
    setting = "FirstLogonCommands"
    content = file("${path.module}/scripts/FirstLogonCommands.xml")
  }

  tags = local.tags
}

resource "azurerm_managed_disk" "windows_vm" {
  count                = var.num_windows_hosts
  name                 = "${var.env_name}-win${count.index + 1}-datadisk"
  location             = azurerm_resource_group.pyp.location
  create_option        = "Empty"
  disk_size_gb         = 50
  resource_group_name  = azurerm_resource_group.pyp.name
  storage_account_type = var.vm_disk_type
}

resource "azurerm_virtual_machine_data_disk_attachment" "windows_vm" {
  count              = var.num_windows_hosts
  virtual_machine_id = azurerm_windows_virtual_machine.windows_vm[count.index].id
  managed_disk_id    = azurerm_managed_disk.windows_vm[count.index].id
  lun                = 0
  caching            = "None"
}


resource "azurerm_key_vault_certificate" "windows_vm" {
  count        = var.num_windows_hosts
  name         = "${var.env_name}-win${count.index + 1}-cert"
  key_vault_id = azurerm_key_vault.pyp.id

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
      subject = "CN=${var.env_name}-win${count.index + 1}"
      subject_alternative_names {
        dns_names = [
          azurerm_public_ip.vm_windows[count.index].fqdn,
          "${var.env_name}-winhost${count.index + 1}"
        ]
      }
      validity_in_months = 12
    }
  }
}