#!/bin/bash

# ==============================================================================
# Azure Container Apps - Commands Cheatsheet
# Lab 07: Scale Containers
# ==============================================================================

# Variables configured according to the 'azure_regions.md' rule
LOCATION="centralindia"
RESOURCE_GROUP="rg-ecommerce"
ENVIRONMENT="my-environment"
ACR_NAME="myregistry"

# ------------------------------------------------------------------------------
# 1. Create a Container App with HTTP Scaling
# ------------------------------------------------------------------------------
# Why: We want to deploy an order-api that scales based on HTTP traffic.
# The rule below scales up when concurrent HTTP requests exceed 50 per replica.
# NOTE (From Rules): We pass registry credentials manually because Managed Identity
# is not supported well in the student/free tier 'Express Environments'.
az containerapp create \
  --name order-api \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image ${ACR_NAME}.azurecr.io/order-api:v1 \
  --min-replicas 0 \
  --max-replicas 10 \
  --scale-rule-name http-scaling \
  --scale-rule-type http \
  --scale-rule-http-concurrency 50 \
  --registry-username "<YOUR_ACR_USERNAME>" \
  --registry-password "<YOUR_ACR_PASSWORD>"

# ------------------------------------------------------------------------------
# 2. Event-Driven Scaling: Service Bus Queue (Secrets-based Auth)
# ------------------------------------------------------------------------------
# Why: We want a background worker to scale up to 30 replicas based on the
# number of messages in an Azure Service Bus queue. If the queue is empty, scale to 0.
az containerapp create \
  --name order-processor \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image ${ACR_NAME}.azurecr.io/order-processor:v1 \
  --min-replicas 0 \
  --max-replicas 30 \
  --secrets "sb-connection=<SERVICE_BUS_CONNECTION_STRING>" \
  --scale-rule-name servicebus-scaling \
  --scale-rule-type azure-servicebus \
  --scale-rule-metadata "queueName=orders" "namespace=sb-ecommerce" "messageCount=5" \
  --scale-rule-auth "connection=sb-connection" \
  --registry-username "<YOUR_ACR_USERNAME>" \
  --registry-password "<YOUR_ACR_PASSWORD>"

# ------------------------------------------------------------------------------
# 3. Event-Driven Scaling: Storage Queue (Managed Identity Auth)
# ------------------------------------------------------------------------------
# Why: We want to scale a simple inventory-updates processor based on an Azure
# Storage Queue, authenticating securely using Managed Identity.
az containerapp create \
  --name queue-processor \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image ${ACR_NAME}.azurecr.io/queue-processor:v1 \
  --user-assigned <MANAGED_IDENTITY_RESOURCE_ID> \
  --min-replicas 0 \
  --max-replicas 20 \
  --scale-rule-name storage-queue-scaling \
  --scale-rule-type azure-queue \
  --scale-rule-metadata "accountName=stecommerce" "queueName=inventory-updates" "queueLength=10" \
  --scale-rule-identity <MANAGED_IDENTITY_RESOURCE_ID> \
  --registry-username "<YOUR_ACR_USERNAME>" \
  --registry-password "<YOUR_ACR_PASSWORD>"
