variable "env_name" {
  description = "Name of Environment"
  default     = "pyp-demo"
}

variable "resource_group_location" {
  default = "westeurope"
}

variable "acr_sku" {
  default = "Basic"
}

variable "cluster_service_principal_client_id" {
  description = "Azure account used by Kubernetes to create resources"
  default     = "00000000-0000-0000-0000-000000000000"
}
variable "cluster_service_principal_client_secret" {
  description = "Azure account used by Kubernetes to create resources"
  default     = "00000000000000000000000000000000"
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

