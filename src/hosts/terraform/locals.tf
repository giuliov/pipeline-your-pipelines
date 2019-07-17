locals {
  tags = {
    environment = var.env_name
  }
  env_name_nosymbols = replace(replace(var.env_name, "-", ""), "_", "")
  name_suffix        = random_id.env_name.hex
  num_hosts          = var.num_windows_hosts + var.num_linux_hosts
}

resource "random_id" "env_name" {
  keepers = {
    env_name = var.env_name
  }

  byte_length = 3
}