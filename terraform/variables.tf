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

# Multi-profile configuration per team/customer/department
variable "report_profiles" {
  type = map(object({
    email_recipients       = list(string)
    advisor_categories     = list(string)
    advisor_threshold_cost = number
    filter_tags            = map(string)
    allowed_resource_types = list(string)
  }))
  default = {}
  description = <<EOD
Map of reporting profiles, each representing a department or customer.
Each profile controls which recipients receive which filtered Advisor alerts.
EOD
}

# (Optional fallback if only using one profile)
variable "email_recipients" {
  type        = list(string)
  default     = ["finops@example.com"]
  description = "List of email addresses to receive filtered Advisor alerts. (used only if report_profiles is empty)"
}

variable "advisor_threshold_cost" {
  type        = number
  default     = 50
  description = "Minimum potential monthly savings required to include an Advisor recommendation."
}

variable "advisor_categories" {
  type        = list(string)
  default     = ["Cost"]
  description = "List of Advisor categories to include in the analysis."
}

variable "filter_tags" {
  type        = map(string)
  default     = {
    environment = "production"
    finops      = "true"
  }
  description = "Map of resource tags used to filter Advisor recommendations (key-value match)."
}

variable "allowed_resource_types" {
  type        = list(string)
  default     = ["Microsoft.Compute/virtualMachines"]
  description = "Optional list of resource types to include when filtering Advisor output."
}
