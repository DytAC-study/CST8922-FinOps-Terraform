# =============================================
# dev.tfvars – Development/Test Configuration for Multi-Profile Mode
# =============================================

location = "East US"
resource_group_name = "rg-cost-automation-dev"

report_profiles = {
  finance = {
    email_recipients       = ["finops@example.com", "cfo@example.com"]
    advisor_categories     = ["Cost"]
    advisor_threshold_cost = 50
    filter_tags = {
      department  = "finance"
      environment = "production"
    }
    allowed_resource_types = ["Microsoft.Compute/virtualMachines"]
  },

  devops = {
    email_recipients       = ["devops@example.com"]
    advisor_categories     = ["HighAvailability"]
    advisor_threshold_cost = 20
    filter_tags = {
      team        = "infrastructure"
      environment = "production"
    }
    allowed_resource_types = ["Microsoft.Sql/servers"]
  },

  clientA = {
    email_recipients       = ["client-a@example.com"]
    advisor_categories     = ["Cost"]
    advisor_threshold_cost = 25
    filter_tags = {
      customer_id = "A001"
    }
    allowed_resource_types = ["Microsoft.Web/sites"]
  }
}
