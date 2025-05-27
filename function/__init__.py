# __init__.py – Azure Function: Filter Advisor recommendations and notify with tag/type filtering

import logging
import os
import requests
from azure.identity import DefaultAzureCredential
from azure.mgmt.advisor import AdvisorManagementClient
import azure.functions as func

# ENV VARS
EMAIL_RECIPIENTS = os.environ.get("EMAIL_RECIPIENTS", "finops@example.com").split(",")
THRESHOLD_COST = float(os.environ.get("ADVISOR_THRESHOLD_COST", 50))
CATEGORIES = os.environ.get("ADVISOR_CATEGORIES", "Cost").split(",")
ALLOWED_RESOURCE_TYPES = os.environ.get("ALLOWED_RESOURCE_TYPES", "").split(",")

# Parse tag filters from comma-separated KEY=VALUE format
TAG_FILTERS = {}
tag_filter_env = os.environ.get("FILTER_TAGS", "")
if tag_filter_env:
    for pair in tag_filter_env.split(","):
        if "=" in pair:
            k, v = pair.split("=", 1)
            TAG_FILTERS[k.strip()] = v.strip()

# Mail sender config (placeholder: customize as needed)
MAIL_ENDPOINT = os.environ.get("MAIL_ENDPOINT", "https://example.com/sendmail")


def match_tags(actual_tags):
    for k, v in TAG_FILTERS.items():
        if k not in actual_tags or actual_tags[k] != v:
            return False
    return True


def main(timer: func.TimerRequest) -> None:
    logging.info("[AdvisorNotifier] Function triggered.")

    credential = DefaultAzureCredential()
    subscription_id = os.environ.get("AZURE_SUBSCRIPTION_ID")
    if not subscription_id:
        logging.error("Missing AZURE_SUBSCRIPTION_ID in environment variables.")
        return

    client = AdvisorManagementClient(credential, subscription_id)
    recommendations = client.recommendations.list()

    filtered = []
    for rec in recommendations:
        if rec.category not in CATEGORIES:
            continue
        if not rec.impact or not rec.impact.potential_cost:
            continue

        cost = rec.impact.potential_cost.amount
        if cost < THRESHOLD_COST:
            continue

        resource_id = rec.resource_metadata.resource_id
        if ALLOWED_RESOURCE_TYPES:
            matched = any(rt.lower() in resource_id.lower() for rt in ALLOWED_RESOURCE_TYPES)
            if not matched:
                continue

        actual_tags = rec.resource_metadata.tags or {}
        if not match_tags(actual_tags):
            continue

        filtered.append({
            "name": rec.name,
            "category": rec.category,
            "resource": resource_id,
            "cost": cost,
            "short_description": rec.short_description.problem or "",
            "tags": actual_tags
        })

    logging.info(f"[AdvisorNotifier] Found {len(filtered)} filtered recommendations.")

    if not filtered:
        return

    # Construct HTML report
    html = "<h2>Azure Advisor – Filtered Recommendations</h2><ul>"
    for item in filtered:
        html += f"<li><strong>{item['name']}</strong> – {item['category']}<br>"
        html += f"Resource: {item['resource']}<br>"
        html += f"Potential Savings: ${item['cost']}<br>"
        html += f"Tags: {item['tags']}<br>"
        html += f"Note: {item['short_description']}</li><br><br>"
    html += "</ul>"

    # Send email via external service (loop per recipient)
    for recipient in EMAIL_RECIPIENTS:
        logging.info(f"[AdvisorNotifier] Sending to {recipient}...")
        try:
            resp = requests.post(MAIL_ENDPOINT, json={
                "to": recipient,
                "subject": "Azure Advisor Report",
                "html": html
            })
            logging.info(f"[AdvisorNotifier] Status: {resp.status_code}")
        except Exception as e:
            logging.error(f"Email send failed to {recipient}: {e}")
