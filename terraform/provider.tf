# =============================================
# provider.tf – AzureRM Provider Configuration
# =============================================

provider "azurerm" {
  features {}

  # Optional: enable logging or diagnostics here
  # skip_provider_registration = true
  # partner_id = "your-partner-id"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }

  required_version = ">= 1.3.0"
}
