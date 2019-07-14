
output "acr_url" {
  value = azurerm_container_registry.pyp.login_server
}

output "vault_uri" {
  value = azurerm_key_vault.pyp.vault_uri
}

output "vm_admin_password" {
  value = random_string.vm_admin_password.result
}