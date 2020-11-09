output "acr_url" {
  value = data.azurerm_container_registry.pyp.login_server
}

output "kube_host" {
  value = azurerm_kubernetes_cluster.pyp.kube_config[0].host
}

locals {
  client_certificate_path = "${abspath(path.module)}/azurek8s.crt"
  kube_config_path        = "${abspath(path.module)}/azurek8s.config"
}

resource "local_file" "client_certificate" {
  content  = azurerm_kubernetes_cluster.pyp.kube_config[0].client_certificate
  filename = local.client_certificate_path
}

resource "local_file" "kube_config" {
  content  = azurerm_kubernetes_cluster.pyp.kube_config_raw
  filename = local.kube_config_path
}

output "kube_config_path" {
  value = local.kube_config_path
}

output "recommend_kube_config" {
  value = <<EOF

# run this command in bash to use the new AKS clusters
export KUBECONFIG=${local.kube_config_path}
# or in PowerShell
$KUBECONFIG = "${local.kube_config_path}"
EOF
}

/*
output "recommend_acr" {
  value = <<EOF

# use this environment variable in bash
export ACR_HOSTNAME=${azurerm_container_registry.pyp.login_server}
# or in PowerShell
$ACR_HOSTNAME = "${azurerm_container_registry.pyp.login_server}"
EOF
}
*/