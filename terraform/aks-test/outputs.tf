output "aks_test_resource_group_name" {
  description = "Resource group holding TEST AKS and its networking."
  value       = azurerm_resource_group.aks_test.name
}

output "aks_test_cluster_name" {
  description = "Name of the TEST AKS cluster."
  value       = azurerm_kubernetes_cluster.aks_test.name
}

output "aks_test_node_resource_group" {
  description = "AKS-managed node resource group (VMSS, disks, LB/public IPs created later by Kubernetes Services) - separate from aks_test_resource_group_name."
  value       = azurerm_kubernetes_cluster.aks_test.node_resource_group
}

output "aks_test_kubelet_identity_object_id" {
  description = "Object (principal) ID of the AKS cluster's auto-created kubelet identity. Granted AcrPull only (see rbac.tf) - no other role."
  value       = azurerm_kubernetes_cluster.aks_test.kubelet_identity[0].object_id
}

output "aks_test_cluster_identity_principal_id" {
  description = "Principal ID of the AKS control-plane's system-assigned identity (distinct from the kubelet identity above). Not granted any role by this layer."
  value       = azurerm_kubernetes_cluster.aks_test.identity[0].principal_id
}
