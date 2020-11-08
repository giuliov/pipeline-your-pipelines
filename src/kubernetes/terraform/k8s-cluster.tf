locals {
  aks_net            = "10.200.0.0/16"
  service_cidr       = cidrsubnet(var.virtual_network_address_space, 8, 1)
  kubernetes_version = var.kubernetes_version
  cluster_name       = "${var.env_name}-clu"
}

resource "random_string" "windows_profile_password" {
  keepers = {
    env_name = var.env_name
  }
  length           = 24
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "!@-_=+."
}

# requires Azure Provider 1.37+
resource "azurerm_kubernetes_cluster" "pyp" {
  name                = local.cluster_name
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name
  dns_prefix          = local.env_name_nosymbols
  kubernetes_version  = local.kubernetes_version

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_D2s_v3"
    os_disk_size_gb = 80
  }

  windows_profile {
    admin_username = "winadm"
    admin_password = random_string.windows_profile_password.result
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = cidrhost(local.service_cidr, 10)
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = local.service_cidr
    load_balancer_sku  = "standard"
  }

  service_principal {
    client_id     = azuread_service_principal.aks_sp.application_id
    client_secret = random_string.aks_sp_password.result
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.pyp.id
    }
  }

  tags = local.tags
}


resource "azurerm_kubernetes_cluster_node_pool" "pyp" {
  name                  = "win"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.pyp.id
  vm_size               = "Standard_D2s_v3"
  os_type               = "Windows"
  os_disk_size_gb       = 100
  node_count            = 1
}
