variable "project" {
  description = "Short project identifier used in resource naming."
  type        = string
  default     = "petclinic-poc"
}

variable "location" {
  description = "Azure region for POC infrastructure created by this layer. Confirm quota/SKU availability for your own subscription before applying."
  type        = string
  default     = "centralindia"
}

variable "tags" {
  description = "Common tags applied to resources created by this layer."
  type        = map(string)
  default = {
    Project    = "GitLab-DevSecOps-Azure-POC"
    ManagedBy  = "Terraform"
    Disposable = "true"
  }
}

# --- Azure CI VM ---

variable "ci_vnet_address_space" {
  description = "Address space for the CI VNet. Sized for a single VM, not for growth."
  type        = list(string)
  default     = ["10.60.0.0/24"]
}

variable "ci_subnet_address_prefixes" {
  description = "Address prefixes for the CI subnet."
  type        = list(string)
  default     = ["10.60.0.0/26"]
}

variable "ssh_source_address_prefix" {
  description = <<-EOT
    Single source IP/CIDR (e.g. "203.0.113.4/32") allowed to reach the CI
    VM over SSH (port 22). No default - must be supplied explicitly so the
    VM is never accidentally opened to the whole internet. Update this and
    re-apply whenever your source IP changes.
  EOT
  type        = string

  validation {
    condition     = var.ssh_source_address_prefix != "*" && var.ssh_source_address_prefix != "0.0.0.0/0"
    error_message = "ssh_source_address_prefix must not be a wildcard/open range; use a single known IP or CIDR."
  }
}

variable "ci_admin_username" {
  description = "Admin username for the CI VM."
  type        = string
  default     = "azureuser"
}

variable "ci_ssh_public_key" {
  description = "SSH public key content for the CI VM admin user. No default - password authentication is disabled, so a real key must be supplied."
  type        = string
}

variable "ci_vm_size" {
  description = <<-EOT
    VM size for the CI VM. Standard_B2as_v2 (2 vCPU, 8 GiB RAM, AMD-based
    burstable) is the minimal size expected to run GitLab Runner + Docker
    Engine + Trivy + Maven/JDK builds + SonarQube Community Build without
    constant CPU credit exhaustion, while staying in the low-cost B-series
    family. Confirm availability in your target region/subscription.
  EOT
  type        = string
  default     = "Standard_B2as_v2"
}

variable "ci_vm_image_version" {
  description = "Pinned Ubuntu 22.04 LTS (gen2) marketplace image version for the CI VM. Confirm the exact version string is still available in your target region via `az vm image list`."
  type        = string
  default     = "22.04.202608060"
}
