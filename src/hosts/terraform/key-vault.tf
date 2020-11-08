resource "azurerm_key_vault" "pyp" {
  name                = "${local.env_name_nosymbols}${local.name_suffix}"
  resource_group_name = azurerm_resource_group.pyp.name
  location            = azurerm_resource_group.pyp.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "create",
      "delete",
      "get",
      "update",
    ]
    key_permissions = []
    secret_permissions = [
      "delete",
      "get",
      "set",
    ]
  }

  tags = local.tags

  lifecycle {
    prevent_destroy = true
  }
}



resource "random_string" "vm_admin_password" {
  keepers = {
    env_name = var.env_name
  }
  length           = 24
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  override_special = "!-_=+"
}

resource "azurerm_key_vault_secret" "pyp_vm_admin" {
  name         = "vm-admin"
  value        = random_string.vm_admin_password.result
  content_type = "password"
  key_vault_id = azurerm_key_vault.pyp.id

  tags = local.tags
}
