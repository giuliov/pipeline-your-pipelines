variable "env_name" {
  description = "Name of Environment"
  default     = "pyp-k8sdemo"
}

variable "resource_group_location" {
  default = "westeurope"
}

variable "kubernetes_version" {
  default = "1.18.10"
}

variable "acr_sku" {
  default = "Basic"
}

variable log_analytics_workspace_sku {
  description = "The pricing SKU of the Log Analytics workspace."
  default     = "PerGB2018"
}

variable "container_registry_name" {
  description = "Azure account used by Kubernetes to create resources"
}

variable "container_registry_resource_group_name" {
  description = "Azure account used by Kubernetes to create resources"
}

variable "virtual_network_address_space" {
  default = "10.0.0.0/8"
}


variable "azuredevops_pat" {
  description = "Azure DevOps Personal Access Token with have Read & manage permission at Agent Pools scope."
  type        = string
  default     = null
}

variable "azuredevops_url" {
  description = "Azure DevOps URL."
  type        = string
  default     = null
}

variable "azuredevops_pool_hosts" {
  description = "Azure DevOps Pool for Hosts."
  type        = string
  default     = null
}

