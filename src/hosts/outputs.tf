
output "acr_url" {
  value = azurerm_container_registry.pyp.login_server
}

output "vault_uri" {
  value = azurerm_key_vault.pyp.vault_uri
}

output "vm_admin_password" {
  value = random_string.vm_admin_password.result
}

output "vm_windows_dns" {
  value = azurerm_public_ip.vm_windows.*.fqdn
}

output "vm_windows_public_ip" {
  value = azurerm_public_ip.vm_windows.*.ip_address
}

output "vm_linux_dns" {
  value = azurerm_public_ip.vm_linux.*.fqdn
}

output "vm_linux_public_ip" {
  value = azurerm_public_ip.vm_linux.*.ip_address
}