# Dedicated resource group for TEST AKS and its networking, kept separate
# from ../main (CI VM) and ../acr (shared registry) so this layer's
# footprint can be inspected/torn down independently.

resource "azurerm_resource_group" "aks_test" {
  name     = "rg-${var.project}-aks-test"
  location = var.location
  tags     = var.tags
}
