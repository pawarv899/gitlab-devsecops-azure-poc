# TEST AKS cluster: Free tier control plane, kubenet networking, one
# system node pool on a cost-conscious, capacity-verified VM size (see
# docs/production-readiness.md for the resource-budget analysis this was
# based on).
#
# Identity model: the cluster itself uses a system-assigned identity
# (control-plane operations only). AKS auto-creates a separate kubelet
# identity for this configuration - that identity is what actually needs
# ACR pull access, granted in rbac.tf. No other identity (including any
# CI VM identity) receives any role on this cluster - no cluster-admin,
# no AKS RBAC of any kind.

resource "azurerm_kubernetes_cluster" "aks_test" {
  name                = "aks-${var.project}-test"
  location            = azurerm_resource_group.aks_test.location
  resource_group_name = azurerm_resource_group.aks_test.name
  dns_prefix          = "${var.project}-aks-test"

  kubernetes_version = var.aks_kubernetes_version
  sku_tier           = "Free"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = "system"
    node_count     = var.aks_node_count
    vm_size        = var.aks_node_vm_size
    vnet_subnet_id = azurerm_subnet.aks_test.id
    type           = "VirtualMachineScaleSets"

    # Managed OS disk - Standard SSD is not an available OS-disk tier for
    # AKS Managed disks (Premium SSD is the only Managed OS disk tier AKS
    # offers); confirm your chosen VM size's Ephemeral OS disk support
    # via `az vm list-skus` before assuming otherwise. No os_disk_size_gb
    # override here - AKS applies its own default sizing for the vCPU
    # count.
    os_disk_type = "Managed"

    # No zones pinned - confirm zone availability for your chosen VM size
    # in your subscription/region via `az vm list-skus` before adding
    # zone pinning; some SKUs are zone-restricted per subscription.

    tags = var.tags
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"

    # Pod/Service CIDRs are AKS-internal overlay ranges, not drawn from
    # the node VNet/subnet - chosen to avoid overlapping the node subnet
    # or ../main's CI VNet.
    pod_cidr       = var.aks_pod_cidr
    service_cidr   = var.aks_service_cidr
    dns_service_ip = var.aks_dns_service_ip
  }

  tags = var.tags
}
