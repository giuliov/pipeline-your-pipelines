locals {
  aks_net            = "10.200.0.0/16"
  service_cidr       = cidrsubnet(var.virtual_network_address_space, 8, 1)
  kubernetes_version = "1.14.7"
}


# requires Azure Provider 1.37.0
resource "azurerm_kubernetes_cluster" "pyp" {
  name                = "${var.env_name}-clu"
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
    admin_username = "cluadm"
    admin_password = "Passw0rd!"
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = cidrhost(local.service_cidr, 10)
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = local.service_cidr
    load_balancer_sku  = "standard"
  }

  service_principal {
    client_id     = var.cluster_service_principal_client_id
    client_secret = var.cluster_service_principal_client_secret
  }

  tags = local.tags
}


resource "azurerm_kubernetes_cluster_node_pool" "pyp" {
  name                  = "win"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.pyp.id
  vm_size               = "Standard_D2s_v3"
  os_type               = "Windows"
  node_count            = 1
}





