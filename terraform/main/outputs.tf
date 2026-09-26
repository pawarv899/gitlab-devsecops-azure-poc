output "ci_resource_group_name" {
  description = "Resource group holding the Azure CI VM and its networking."
  value       = azurerm_resource_group.ci.name
}

output "ci_vm_name" {
  description = "Name of the Azure CI VM."
  value       = azurerm_linux_virtual_machine.ci.name
}

output "ci_vm_public_ip" {
  description = "Public IP address of the Azure CI VM."
  value       = azurerm_public_ip.ci.ip_address
}

output "ci_vm_private_ip" {
  description = "Private IP address of the Azure CI VM."
  value       = azurerm_network_interface.ci.private_ip_address
}

output "ci_vm_system_identity_principal_id" {
  description = "Principal (object) ID of the CI VM's system-assigned managed identity. Used by ../acr/rbac.tf to grant least-privilege ACR access."
  value       = azurerm_linux_virtual_machine.ci.identity[0].principal_id
}
