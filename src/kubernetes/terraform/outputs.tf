
output "acr_url" {
  value = azurerm_container_registry.pyp.login_server
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.pyp.kube_config[0].client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.pyp.kube_config_raw
}

output "kube_host" {
  value = "${azurerm_kubernetes_cluster.pyp.kube_config.[0].host}"
}
# echo "$(terraform output kube_config)" > ~/.kube/azurek8s
# export KUBECONFIG=~/.kube/azurek8s