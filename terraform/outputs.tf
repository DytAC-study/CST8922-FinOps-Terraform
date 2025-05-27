# =============================================
# outputs.tf – Useful outputs after deployment
# =============================================

# Public URL of the Function App (default domain)
output "function_app_url" {
  description = "Base URL of the deployed Function App"
  value       = "https://${azurerm_function_app.advisor_func.default_hostname}"
}

# Resource Group name confirmation
output "resource_group" {
  description = "The name of the resource group used"
  value       = azurerm_resource_group.advisor.name
}

# Function App identity object ID
output "function_identity_principal_id" {
  description = "The Managed Identity object ID of the Function App (used for role assignments or Graph access)"
  value       = azurerm_function_app.advisor_func.identity[0].principal_id
}