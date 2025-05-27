# =============================================
# dev.tfvars – Development/Test Configuration Example
# =============================================

# Azure location for all resources
location = "East US"

# Resource group name (can be reused across environments)
resource_group_name = "rg-cost-automation-dev"

# Who should receive the Advisor alerts
email_recipients = [
  "dev-finops@example.com",
  "cloud-ops@example.com"
]

# Only include Advisor recommendations with potential savings >= $50/month
advisor_threshold_cost = 50

# Limit Advisor to these categories
advisor_categories = [
  "Cost",
  "HighAvailability"
]

# Only include resources with all matching tags
filter_tags = {
  environment = "production"
  finops      = "true"
  department  = "engineering"
}

# Restrict output to only these resource types (optional)
allowed_resource_types = [
  "Microsoft.Compute/virtualMachines",
  "Microsoft.Sql/servers"
]