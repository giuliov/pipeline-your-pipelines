terraform {
  required_version = ">= 0.13"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.0.0"

    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.34.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
}
