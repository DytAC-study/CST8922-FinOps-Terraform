# =============================================
# main.tf – Multi-profile Function App deployment
# =============================================

resource "azurerm_resource_group" "advisor" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_integer" "suffix" {
  for_each = var.report_profiles
  min      = 10000
  max      = 99999
}

resource "azurerm_storage_account" "advisor_sa" {
  for_each                 = var.report_profiles
  name                     = "advsa${random_integer.suffix[each.key].result}"
  resource_group_name      = azurerm_resource_group.advisor.name
  location                 = azurerm_resource_group.advisor.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
}

resource "azurerm_app_service_plan" "advisor_plan" {
  for_each            = var.report_profiles
  name                = "advisor-plan-${each.key}"
  location            = azurerm_resource_group.advisor.location
  resource_group_name = azurerm_resource_group.advisor.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "advisor_func" {
  for_each = var.report_profiles

  name                       = "advisor-func-${each.key}"
  location                   = azurerm_resource_group.advisor.location
  resource_group_name        = azurerm_resource_group.advisor.name
  app_service_plan_id        = azurerm_app_service_plan.advisor_plan[each.key].id
  storage_account_name       = azurerm_storage_account.advisor_sa[each.key].name
  storage_account_access_key = azurerm_storage_account.advisor_sa[each.key].primary_access_key
  os_type                    = "linux"
  version                    = "4"
  functions_extension_version = "~4"

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME   = "python"
    EMAIL_RECIPIENTS           = join(",", each.value.email_recipients)
    ADVISOR_THRESHOLD_COST     = tostring(each.value.advisor_threshold_cost)
    ADVISOR_CATEGORIES         = join(",", each.value.advisor_categories)
    FILTER_TAGS                = join(",", [for k, v in each.value.filter_tags : "${k}=${v}"])
    ALLOWED_RESOURCE_TYPES     = join(",", each.value.allowed_resource_types)
  }

  identity {
    type = "SystemAssigned"
  }
}

output "function_urls" {
  value = {
    for profile, app in azurerm_function_app.advisor_func :
    profile => "https://${app.default_hostname}"
  }
}
