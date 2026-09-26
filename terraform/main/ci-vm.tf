# The Azure CI VM itself. GitLab Runner, Docker Engine, Trivy, JDK/Maven
# and SonarQube are installed/configured on top of this VM outside
# Terraform (see docs/architecture.md).
#
# System-assigned managed identity is created here with NO role
# assignments by default. Granting it any role (ACR push - see
# ../acr/rbac.tf - and never AKS cluster-admin) is a separate, explicit
# decision.

resource "azurerm_linux_virtual_machine" "ci" {
  name                = "vm-${var.project}-ci"
  location            = azurerm_resource_group.ci.location
  resource_group_name = azurerm_resource_group.ci.name
  size                = var.ci_vm_size
  admin_username      = var.ci_admin_username

  network_interface_ids = [
    azurerm_network_interface.ci.id,
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.ci_admin_username
    public_key = var.ci_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 64 # headroom over the image default for Docker image/layer storage
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = var.ci_vm_image_version
  }

  identity {
    type = "SystemAssigned"
  }

  # Managed boot diagnostics storage - no separate storage account needed.
  boot_diagnostics {}

  tags = var.tags
}
