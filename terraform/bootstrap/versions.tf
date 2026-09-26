terraform {
  required_version = ">= 1.16.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Deliberately no backend block here: the bootstrap layer creates the
  # remote-state storage itself, so it cannot depend on it. Bootstrap
  # state stays local. Do not add an azurerm backend to this layer.
}
