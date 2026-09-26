variable "project" {
  description = "Short project identifier used in resource naming."
  type        = string
  default     = "petclinic-poc"
}

variable "location" {
  description = "Azure region for TEST AKS. Should match the region used by ../main and ../acr."
  type        = string
  default     = "centralindia"
}

variable "tags" {
  description = "Common tags applied to resources created by this layer."
  type        = map(string)
  default = {
    Project     = "GitLab-DevSecOps-Azure-POC"
    ManagedBy   = "Terraform"
    Layer       = "aks-test"
    Environment = "test"
    Disposable  = "true"
  }
}

# --- Cross-layer state read (../acr, for the shared ACR's resource ID) ---

variable "tfstate_resource_group_name" {
  description = "Resource group holding the shared Terraform state storage account (from ../bootstrap)."
  type        = string
  default     = "rg-petclinic-poc-tfstate"
}

variable "tfstate_storage_account_name" {
  description = "Storage account holding Terraform state (from ../bootstrap output: storage_account_name). No default - environment-specific generated value."
  type        = string
}

variable "tfstate_container_name" {
  description = "Blob container holding Terraform state files (from ../bootstrap)."
  type        = string
  default     = "tfstate"
}

# --- Networking (kubenet) ---

variable "aks_vnet_address_space" {
  description = "Address space for the TEST AKS VNet."
  type        = list(string)
  default     = ["10.70.0.0/24"]
}

variable "aks_subnet_address_prefixes" {
  description = "Address prefixes for the TEST AKS node subnet."
  type        = list(string)
  default     = ["10.70.0.0/26"]
}

variable "aks_pod_cidr" {
  description = "Pod overlay CIDR for kubenet. Must not overlap the node VNet/subnet or other VNets in your subscription."
  type        = string
  default     = "10.244.0.0/16"
}

variable "aks_service_cidr" {
  description = "Kubernetes Service CIDR (ClusterIP range) for kubenet. Must not overlap the node VNet/subnet or the pod CIDR."
  type        = string
  default     = "10.100.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "IP address (within aks_service_cidr) used for the cluster's internal DNS service."
  type        = string
  default     = "10.100.0.10"
}

# --- AKS cluster ---

variable "aks_kubernetes_version" {
  description = "Pinned Kubernetes version for TEST AKS. Confirm current availability/support via `az aks get-versions --location <region>` before applying - AKS's supported version window moves over time."
  type        = string
  default     = "1.36.4"
}

variable "aks_node_vm_size" {
  description = <<-EOT
    VM size for the TEST AKS system node pool. Confirm availability for
    your subscription/region via `az vm list-skus` before applying - some
    SKUs are restricted per-subscription in specific zones, and SKU
    generations are retired/introduced over time.
  EOT
  type        = string
  default     = "Standard_D2s_v5"
}

variable "aks_node_count" {
  description = <<-EOT
    Number of nodes in the TEST AKS system node pool. Starts at 1 node.
    Scaling later is a matter of changing this value and re-applying - no
    cluster autoscaler is configured, keeping node count (and cost)
    explicit and predictable.
  EOT
  type        = number
  default     = 1

  validation {
    condition     = var.aks_node_count >= 1 && var.aks_node_count <= 2
    error_message = "aks_node_count must be 1 or 2 for this cost-conscious TEST layer; raise the constraint deliberately if a real need for more nodes arises."
  }
}
