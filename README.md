# Azure Advisor Notifier – Cost Optimization Automation

This project implements an Azure Function + Terraform-based solution that regularly analyzes Azure Advisor recommendations, filters them based on cost, tags, resource types, and other rules, and notifies stakeholders via email.

It is designed for FinOps and CloudOps teams managing large Azure environments.

---

## 📁 Project Structure

```bash
azure-advisor-notifier/
├── terraform/               # Infrastructure-as-Code with Terraform
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── backend.tf
│   ├── tfstate_storage.tf
│   └── dev.tfvars
│
├── function/                # Azure Function (Python) logic
│   ├── __init__.py
│   ├── requirements.txt
│   ├── function.json
│   └── local.settings.json
│
├── scripts/                 # Optional CLI tools for testing
│   └── test_advisor_api.py
│
├── .gitignore
└── README.md
```

---

## 🛠️ Features

- Uses **Azure Advisor** to identify optimization opportunities (e.g., RI underuse)
- Filters recommendations based on:
  - Minimum potential savings (cost threshold)
  - Specific categories (e.g., Cost, HighAvailability)
  - Required tags on affected resources
  - Allowed resource types (e.g., Virtual Machines only)
- Sends formatted email reports to one or more recipients
- Runs on a schedule via **Timer Triggered Azure Function**
- Infrastructure is defined via **Terraform** and deployed in two phases

---

## 📦 Terraform Deployment (Remote Backend Setup)

### 1️⃣ Step 1: Deploy backend storage for Terraform state

```bash
cd terraform
terraform init
terraform apply -target=azurerm_resource_group.tfstate \
                -target=azurerm_storage_account.tfstate \
                -target=azurerm_storage_container.tfstate
```

**Note the outputs** and update `backend.tf` accordingly:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstateXXXX"
    container_name       = "tfstate"
    key                  = "advisor-dev.tfstate"
  }
}
```

### 2️⃣ Step 2: Initialize and deploy Azure infrastructure

```bash
terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=tfstateXXXX" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=advisor-dev.tfstate"

terraform apply -var-file=dev.tfvars
```

---

## 🔧 Environment Variables

These are injected automatically via Terraform into the Function App:

| Variable | Description |
|----------|-------------|
| `EMAIL_RECIPIENTS` | Comma-separated list of emails |
| `ADVISOR_THRESHOLD_COST` | Minimum monthly savings required |
| `ADVISOR_CATEGORIES` | Categories to include (e.g., Cost) |
| `FILTER_TAGS` | Format: `key1=value1,key2=value2` |
| `ALLOWED_RESOURCE_TYPES` | Resource types to include |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID |
| `MAIL_ENDPOINT` | Email API endpoint (e.g., SendGrid, webhook) |

---

## 🔄 Function Logic (`function/__init__.py`)

- Uses `DefaultAzureCredential` for auth (make sure MSI is enabled)
- Pulls all Advisor recommendations
- Applies filters:
  - Cost >= threshold
  - Category match
  - Tag match (all key=value pairs must exist)
  - Resource type match
- Generates HTML summary report
- Sends email to all recipients via POST to `MAIL_ENDPOINT`

---

## 🧪 Local Development

Install requirements:
```bash
cd function
pip install -r requirements.txt
```

Run with Azure Functions Core Tools:
```bash
func start
```

Local config (`local.settings.json`) includes all env vars.

---

## 🧰 Test Script

To verify your Azure credentials and Advisor access:

```bash
python scripts/test_advisor_api.py
```

---

## 🚀 Future Enhancements

- Role-based alert routing via tags or metadata
- Power BI Embedded dashboard for FinOps reporting
- Approval-based RI purchases via Logic Apps
- Integration with Microsoft Graph for secure mail delivery
- Dynamic exclusion rules or recommendation lifecycle tracking

---

## 📬 Contact / Team

Built for CST8922 – Cloud Infrastructure Design and Automation.
For questions or contributions, please contact your team lead or FinOps architect.
