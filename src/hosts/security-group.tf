# Trick to guarantee that we can access the target VM
data "external" "client_ip" {
  program = ["curl", "https://api.ipify.org/?format=json"]
}

locals {
  network_security_rule_base_priority = 2000
}


resource "azurerm_network_security_group" "vm_windows" {
  name                = "${var.env_name}-vm-windows-sg"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name
}

resource "azurerm_subnet_network_security_group_association" "vm_windows_subnet" {
  subnet_id                 = azurerm_subnet.vm_windows_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_windows.id
}

resource "azurerm_network_security_group" "vm_linux" {
  name                = "${var.env_name}-vm-linux-sg"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name
}

resource "azurerm_subnet_network_security_group_association" "vm_linux_subnet" {
  subnet_id                 = azurerm_subnet.vm_linux_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_linux.id
}

resource "azurerm_network_security_rule" "vm_windows_rdp_in" {
  name                        = "${var.env_name}-rdp-in"
  priority                    = local.network_security_rule_base_priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = data.external.client_ip.result["ip"]
  destination_address_prefix  = azurerm_subnet.vm_windows_subnet.address_prefix
  resource_group_name         = azurerm_resource_group.pyp.name
  network_security_group_name = azurerm_network_security_group.vm_windows.name
}

resource "azurerm_network_security_rule" "vm_windows_winrm_in" {
  name                        = "${var.env_name}-winrm-in"
  priority                    = azurerm_network_security_rule.vm_windows_rdp_in.priority + 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5985-5986"
  source_address_prefix       = data.external.client_ip.result["ip"]
  destination_address_prefix  = azurerm_subnet.vm_windows_subnet.address_prefix
  resource_group_name         = azurerm_resource_group.pyp.name
  network_security_group_name = azurerm_network_security_group.vm_windows.name
}

resource "azurerm_network_security_rule" "vm_linux_ssh_in" {
  name                        = "${var.env_name}-ssh-in"
  priority                    = local.network_security_rule_base_priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = data.external.client_ip.result["ip"]
  destination_address_prefix  = azurerm_subnet.vm_linux_subnet.address_prefix
  resource_group_name         = azurerm_resource_group.pyp.name
  network_security_group_name = azurerm_network_security_group.vm_linux.name
}
