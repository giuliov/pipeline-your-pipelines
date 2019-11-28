
resource "azurerm_log_analytics_workspace" "pyp" {
  name                = "${var.env_name}-loga"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name
  sku                 = var.log_analytics_workspace_sku

  lifecycle {
    ignore_changes = [
      name,
    ]
  }
}

resource "azurerm_log_analytics_solution" "pyp-containerinsights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.pyp.location
  resource_group_name   = azurerm_resource_group.pyp.name
  workspace_resource_id = azurerm_log_analytics_workspace.pyp.id
  workspace_name        = azurerm_log_analytics_workspace.pyp.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}