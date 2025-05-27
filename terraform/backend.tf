# =============================================
# backend.tf – Remote state configuration using Azure Storage
# =============================================

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstatebackendsa"
    container_name       = "tfstate"
    key                  = "advisor-dev.tfstate"
  }
}