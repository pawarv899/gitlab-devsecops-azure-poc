# Minimal networking for a single CI VM: one VNet, one subnet, one NSG
# scoped to SSH from a single known source, a static public IP, and a NIC.
# No NAT Gateway, Bastion, Load Balancer or private endpoints - not
# justified for one disposable CI VM.

resource "azurerm_virtual_network" "ci" {
  name                = "vnet-${var.project}-ci"
  address_space       = var.ci_vnet_address_space
  location            = azurerm_resource_group.ci.location
  resource_group_name = azurerm_resource_group.ci.name
  tags                = var.tags
}

resource "azurerm_subnet" "ci" {
  name                 = "snet-ci"
  resource_group_name  = azurerm_resource_group.ci.name
  virtual_network_name = azurerm_virtual_network.ci.name
  address_prefixes     = var.ci_subnet_address_prefixes
}

resource "azurerm_network_security_group" "ci" {
  name                = "nsg-${var.project}-ci"
  location            = azurerm_resource_group.ci.location
  resource_group_name = azurerm_resource_group.ci.name
  tags                = var.tags

  security_rule {
    name                       = "AllowSSHFromKnownIP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_source_address_prefix
    destination_address_prefix = "*"
  }

  # No other inbound rules: everything else falls through to the NSG's
  # implicit default-deny. Outbound keeps Azure's default-allow, needed
  # for package installs, image pulls, and GitLab Runner polling
  # gitlab.com (and pushing to ACR).
}

resource "azurerm_subnet_network_security_group_association" "ci" {
  subnet_id                 = azurerm_subnet.ci.id
  network_security_group_id = azurerm_network_security_group.ci.id
}

resource "azurerm_public_ip" "ci" {
  name                = "pip-${var.project}-ci"
  location            = azurerm_resource_group.ci.location
  resource_group_name = azurerm_resource_group.ci.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "ci" {
  name                = "nic-${var.project}-ci"
  location            = azurerm_resource_group.ci.location
  resource_group_name = azurerm_resource_group.ci.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ci.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ci.id
  }
}
