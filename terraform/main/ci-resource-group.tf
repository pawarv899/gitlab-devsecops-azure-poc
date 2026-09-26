# Dedicated resource group for the Azure CI VM and its networking, kept
# separate from ACR/AKS resource groups (see ../acr, ../aks-test) so the
# CI footprint can be inspected/torn down independently.

resource "azurerm_resource_group" "ci" {
  name     = "rg-${var.project}-ci"
  location = var.location
  tags     = var.tags
}
