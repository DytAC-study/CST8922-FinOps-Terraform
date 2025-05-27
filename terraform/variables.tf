# =============================================
# variables.tf – Configurable Parameters for Advisor Analysis
# =============================================

# Azure Region for resource deployment
variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region where resources will be created."
}

# Resource Group name
variable "resource_group_name" {
  type        = string
  default     = "rg-cost-automation"
  description = "Name of the resource group to contain all FinOps resources."
}

# Email recipients for Advisor reports (supports multiple recipients)
variable "email_recipients" {
  type        = list(string)
  default     = ["finops@example.com"]
  description = "List of email addresses to receive filtered Advisor alerts."
}

# Minimum potential savings (USD) for an Advisor recommendation to be included
variable "advisor_threshold_cost" {
  type        = number
  default     = 50
  description = "Minimum potential monthly savings required to include an Advisor recommendation."
}

# Advisor categories to include (e.g., Cost, Security, Reliability)
variable "advisor_categories" {
  type        = list(string)
  default     = ["Cost"]
  description = "List of Advisor categories to include in the analysis."
}

# Tags to match on Advisor-affected resources (e.g., only tagged 'cost-critical')
variable "filter_tags" {
  type        = map(string)
  default     = {
    environment = "production"
    finops      = "true"
  }
  description = "Map of resource tags used to filter Advisor recommendations (key-value match)."
}

# Optionally specify allowed resource types (e.g., only apply to VirtualMachines)
variable "allowed_resource_types" {
  type        = list(string)
  default     = ["Microsoft.Compute/virtualMachines"]
  description = "Optional list of resource types to include when filtering Advisor output."
}