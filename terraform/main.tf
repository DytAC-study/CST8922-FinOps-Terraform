# =============================================
# main.tf – Step-by-step resource creation for Advisor automation
# =============================================

# Step 1: Create a resource group to contain all related resources
resource "azurerm_resource_group" "advisor" {
  name     = var.resource_group_name
  location = var.location
}


# Step 2: Create a storage account for Function App (required dependency)
resource "azurerm_storage_account" "advisor_sa" {
  name                     = "advisorfuncsa${random_integer.rand.result}"
  resource_group_name      = azurerm_resource_group.advisor.name
  location                 = azurerm_resource_group.advisor.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
}

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}


# Step 3: Create an App Service plan with consumption pricing (dynamic plan)
resource "azurerm_app_service_plan" "advisor_plan" {
  name                = "advisor-app-plan"
  location            = azurerm_resource_group.advisor.location
  resource_group_name = azurerm_resource_group.advisor.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}


# Step 4: Create the Function App that will execute Advisor logic and send email
resource "azurerm_function_app" "advisor_func" {
  name                       = "advisor-func-app"
  location                   = azurerm_resource_group.advisor.location
  resource_group_name        = azurerm_resource_group.advisor.name
  app_service_plan_id        = azurerm_app_service_plan.advisor_plan.id
  storage_account_name       = azurerm_storage_account.advisor_sa.name
  storage_account_access_key = azurerm_storage_account.advisor_sa.primary_access_key
  os_type                    = "linux"
  version                    = "4"
  functions_extension_version = "~4"

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    EMAIL_RECIPIENTS         = join(",", var.email_recipients)
    ADVISOR_THRESHOLD_COST   = tostring(var.advisor_threshold_cost)
    ADVISOR_CATEGORIES       = join(",", var.advisor_categories)
  }

  identity {
    type = "SystemAssigned"
  }
}
