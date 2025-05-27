# scripts/test_advisor_api.py – Simple script to test Azure Advisor API

import os
from azure.identity import DefaultAzureCredential
from azure.mgmt.advisor import AdvisorManagementClient

# Load from env or replace directly
subscription_id = os.environ.get("AZURE_SUBSCRIPTION_ID", "00000000-0000-0000-0000-000000000000")

cred = DefaultAzureCredential()
client = AdvisorManagementClient(credential=cred, subscription_id=subscription_id)

print("Fetching Advisor recommendations...")

recommendations = client.recommendations.list()
for rec in recommendations:
    cost = getattr(getattr(rec.impact, 'potential_cost', None), 'amount', None)
    print("-", rec.name)
    print("  Category:", rec.category)
    print("  Resource:", rec.resource_metadata.resource_id)
    print("  Potential Savings:", f"${cost}" if cost else "N/A")
    print("  Short Desc:", rec.short_description.problem)
    print()
