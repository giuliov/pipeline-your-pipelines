resource "azurerm_kubernetes_cluster" "pyp" {
  name                = "${var.env_name}-cluster"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name
  dns_prefix          = local.env_name_nosymbols

  agent_pool_profile {
    name            = "linux" #default
    count           = 1
    vm_size         = "Standard_B2s"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  # requires Azure Provider 1.32.0
  /*
  agent_pool_profile {
    name            = "windows"
    count           = 1
    vm_size         = "Standard_B2s"
    os_type         = "Windows"
    os_disk_size_gb = 50
  }
  */

  service_principal {
    client_id     = var.cluster_service_principal_client_id
    client_secret = var.cluster_service_principal_client_secret
  }

  tags = local.tags
}
