resource "azurerm_resource_group" "pyp" {
  name     = var.env_name
  location = var.resource_group_location

  tags = local.tags
}