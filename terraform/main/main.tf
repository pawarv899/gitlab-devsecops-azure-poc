# Entry point for the POC's core Azure infrastructure. Resources are
# split into files by concern:
#   ci-resource-group.tf  - dedicated resource group for the CI VM
#   network.tf             - VNet, subnet, NSG, public IP, NIC
#   ci-vm.tf                - the Linux CI VM + system-assigned identity
#
# ACR and TEST AKS are provisioned as separate, independent layers (see
# ../acr and ../aks-test) - not here. No NAT Gateway, Bastion, Load
# Balancer or private endpoints are used - unnecessary for a single
# disposable CI VM.
