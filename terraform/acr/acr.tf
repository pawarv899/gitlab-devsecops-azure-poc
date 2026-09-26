# Shared Azure Container Registry for the POC. One registry serves both
# TEST and PROD (BUILD ONCE -> PUBLISH IMMUTABLE ARTIFACT -> PROMOTE THE
# SAME ARTIFACT means the registry itself is never duplicated per
# environment). Kept in its own resource group, separate from ../main's
# CI VM resource group, so its lifecycle can be inspected/torn down
# independently.

resource "azurerm_resource_group" "acr" {
  name     = "rg-${var.project}-acr"
  location = var.location
  tags     = var.tags
}

# ACR names are globally unique across all of Azure, 5-50 chars,
# alphanumeric only (no hyphens). A random suffix avoids manual collision
# handling for a POC - same pattern ../bootstrap already uses for the
# storage account name.
resource "random_string" "acr_suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  acr_name = substr(
    lower(replace("acr${var.project}${random_string.acr_suffix.result}", "-", "")),
    0, 50
  )
}

resource "azurerm_container_registry" "this" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.acr.name
  location            = azurerm_resource_group.acr.location

  sku = "Basic"

  # No static admin credentials - push/pull happens exclusively via
  # RBAC + managed identity (see rbac.tf). An enabled admin account would
  # be a shared, non-rotatable, non-attributable credential - exactly
  # what this design avoids.
  admin_enabled = false

  # Public network access: Basic SKU does NOT support IP firewall rules
  # or private endpoints at all - those require Premium. Since neither
  # the CI VM nor the AKS clusters have a private network path to this
  # registry, restricting public access on this SKU would simply break
  # push/pull with no Premium-tier alternative available at this cost
  # point. RBAC (AcrPush/AcrPull, see rbac.tf) plus the disabled admin
  # account are the actual security boundary at this tier, not network
  # restriction. Revisit if this project ever moves to Premium - see
  # ../../docs/production-readiness.md.
  public_network_access_enabled = true

  tags = var.tags
}
