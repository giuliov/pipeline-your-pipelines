resource "azurerm_container_registry" "pyp" {
  name                = "${local.env_name_nosymbols}${local.name_suffix}"
  resource_group_name = azurerm_resource_group.pyp.name
  location            = azurerm_resource_group.pyp.location
  sku                 = var.acr_sku
  admin_enabled       = false

  tags = local.tags

  lifecycle {
    prevent_destroy = false
  }
}
