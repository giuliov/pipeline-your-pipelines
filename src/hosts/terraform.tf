terraform {
  required_version = "~> 0.12"
}

provider "azurerm" {
  version         = "~> 1.31"
  subscription_id = var.azurerm_subscription_id
  client_id       = var.azurerm_client_id
  client_secret   = var.azurerm_client_secret
  tenant_id       = var.azurerm_tenant_id
}

variable "azurerm_subscription_id" {}
variable "azurerm_client_id" {}
variable "azurerm_client_secret" {}
variable "azurerm_tenant_id" {}

data "azurerm_client_config" "current" {}

provider "random" {
  version = "~> 2.1"
}
