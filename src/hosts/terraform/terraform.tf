provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true # CAVEAT: this is ok for demoing, a VERY BAD idea otherwise
    }
  }
}

data "azurerm_client_config" "current" {}
