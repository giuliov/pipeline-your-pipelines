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

variable "vm_size" {
  default = "Standard_B1"
}

variable "vm_disk_type" {
  default = "Standard_LRS"
}

variable "vm_admin_username" {
  description = "Username for the Administrator account"
  default     = "hostadmin"
}

variable "vm_public_access" {
  type    = bool
  default = false
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

