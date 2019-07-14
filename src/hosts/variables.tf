variable "env_name" {
  description = "Name of Environment"
  default     = "pyp-demo"
}

variable "resource_group_location" {
  default = "westeurope"
}

variable "num_windows_hosts" {
  type    = number
  default = 1
}

variable "num_linux_hosts" {
  type    = number
  default = 1
}

variable "vm_admin_username" {
  description = "Username for the Administrator account"
  default     = "hostadmin"
}

variable "azuredevops_pat" {
  description = "Azure DevOps Personal Access Token with have Read & manage permission at Agent Pools scope."
  default     = "PAT missing"
}

variable "azuredevops_url" {
  description = "Azure DevOps URL."
}

variable "azuredevops_pool_hosts" {
  description = "Azure DevOps Pool for Hosts."
}

variable "win_agents_folder" {
  description = "Full path for Azure DevOps Agents."
  default     = "C:\\Agents"
}

