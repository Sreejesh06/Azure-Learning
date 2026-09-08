# Azure For Students - Allowed Regions

When working on this machine or within this workspace, the current Azure for Students subscription has strict policy restrictions on regions.

The only allowed regions for deploying resources (like Resource Groups, ACR, and Container Apps) are:
- `malaysiawest`
- `eastasia`
- `centralindia`
- `indiasouthcentral`
- `uaenorth`

**Rule:** 
Always default to using `centralindia` or `eastasia` when providing Azure CLI commands or Terraform scripts that require a location. Do NOT use `eastus` or `westus`.
