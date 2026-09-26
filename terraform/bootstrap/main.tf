# Bootstrap layer: creates ONLY the minimum resources required for a
# Terraform azurerm remote-state backend. See ../../docs/architecture.md.

resource "azurerm_resource_group" "tfstate" {
  name     = var.state_resource_group_name
  location = var.location
  tags     = var.tags
}

# Storage account names must be globally unique across all of Azure,
# 3-24 chars, lowercase letters and digits only. A random suffix avoids
# manual collision handling for a POC.
resource "random_string" "storage_suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  storage_account_name = substr(
    lower(replace("st${var.project}tfstate${random_string.storage_suffix.result}", "-", "")),
    0, 24
  )
}

resource "azurerm_storage_account" "tfstate" {
  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location

  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  # Protects tfstate against accidental overwrite/corruption; cheap for a
  # single small container, so not considered over-engineering here.
  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.state_container_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
