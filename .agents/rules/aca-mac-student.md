# Azure Container Apps on Mac (Apple Silicon) and Student Subscriptions

When working with Azure Container Apps in this workspace, always adhere to the following rules:

1. **Student Subscriptions and ACR Tasks**: 
   When using an "Azure for Students" or free tier subscription, `az acr build` (ACR Tasks) is blocked by Microsoft to prevent crypto-mining abuse. 
   **Rule**: Never use `az acr build`. Instead, build the docker image locally using `docker build` and push using `docker push`. 
   
2. **Apple Silicon (M-Series Mac) Architecture**:
   When building a docker image locally on a Mac with Apple Silicon (ARM64) for deployment to Azure Container Apps, the image must be explicitly built for the AMD64 architecture, because Azure Container Apps only supports `linux/amd64`.
   **Rule**: Always append `--platform linux/amd64` to any `docker build` command intended for Azure.

3. **Express Environments & Managed Identities**:
   Azure Container Apps deployed in "Express Environments" (the default for free/student tiers) do not fully support System-assigned Managed Identities for ACR authentication.
   **Rule**: To pull from an ACR, you must enable admin access on the ACR (`az acr update --admin-enabled true`) and pass `--registry-username` and `--registry-password` to `az containerapp create`. Do NOT use `--registry-identity system`.
