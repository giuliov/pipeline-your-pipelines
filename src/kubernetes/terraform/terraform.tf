provider "azurerm" {
  features {}
}

provider "azuread" {
}

data "azurerm_client_config" "current" {}
