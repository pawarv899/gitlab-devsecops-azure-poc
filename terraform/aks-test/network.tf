# Minimal networking for kubenet: one VNet, one subnet, no NSG rules
# beyond Azure's implicit default-deny inbound (AKS manages its own
# node-level rules; no SSH or other direct access to nodes is needed -
# kubectl/Argo CD talk to the API server, not the nodes). No NAT
# Gateway, Bastion, Application Gateway or private endpoints - not
# justified for a single-node TEST AKS cluster.

resource "azurerm_virtual_network" "aks_test" {
  name                = "vnet-${var.project}-aks-test"
  address_space       = var.aks_vnet_address_space
  location            = azurerm_resource_group.aks_test.location
  resource_group_name = azurerm_resource_group.aks_test.name
  tags                = var.tags
}

resource "azurerm_subnet" "aks_test" {
  name                 = "snet-aks-test"
  resource_group_name  = azurerm_resource_group.aks_test.name
  virtual_network_name = azurerm_virtual_network.aks_test.name
  address_prefixes     = var.aks_subnet_address_prefixes
}
