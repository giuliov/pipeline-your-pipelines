locals {
  aks_net = "10.200.0.0/16"
}

resource "azurerm_kubernetes_cluster" "pyp" {
  name                = "${var.env_name}-cluster"
  location            = azurerm_resource_group.pyp.location
  resource_group_name = azurerm_resource_group.pyp.name
  dns_prefix          = local.env_name_nosymbols
  kubernetes_version  = "1.13.5"

  agent_pool_profile {
    name            = "linux" #default
    count           = 1
    vm_size         = "Standard_D2s_v3"
    os_type         = "Linux"
    os_disk_size_gb = 80
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
    type            = "VirtualMachineScaleSets"
  }

  # requires Azure Provider 1.32.0
  agent_pool_profile {
    name            = "win"
    count           = 1
    vm_size         = "Standard_D2s_v3"
    os_type         = "Windows"
    os_disk_size_gb = 100
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
    type            = "VirtualMachineScaleSets"
  }

  # BUG: should not be mandatory
  windows_profile {
    admin_username = "nodeadmin"
    admin_password = "P@ssw0rd!"
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = cidrhost(local.aks_net, 10)
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = local.aks_net
    load_balancer_sku  = "standard"
  }

  service_principal {
    client_id     = var.cluster_service_principal_client_id
    client_secret = var.cluster_service_principal_client_secret
  }

  tags = local.tags
}
