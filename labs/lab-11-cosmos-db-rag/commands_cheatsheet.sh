#!/bin/bash

# ==============================================================================
# Lab 11: Cosmos DB RAG Document Store - Azure CLI Cheatsheet
# ==============================================================================

# Why: We define our variables upfront to make the script reusable and easy to read.
# Gotcha: We are strictly using 'centralindia' to comply with student subscription policies.
RESOURCE_GROUP="rg-cosmos-rag-lab"
LOCATION="centralindia"
COSMOS_ACCOUNT_NAME="cosmos-rag-$(openssl rand -hex 4)" # Needs to be globally unique
DATABASE_NAME="rag_db"
CONTAINER_NAME="document_chunks"

# 1. Login to Azure
# Why: Authenticates the CLI with your Azure account.
az login

# 2. Register Resource Provider
# Why: Before we can create Cosmos DB resources, Azure needs to know we intend to use the DocumentDB provider.
# Symptom: "The subscription is not registered to use namespace 'Microsoft.DocumentDB'"
# Fix: Run this command.
az provider register --namespace Microsoft.DocumentDB

# 3. Create Resource Group
# Why: Logical container for all our Azure resources.
az group create --name $RESOURCE_GROUP --location $LOCATION

# 4. Create Cosmos DB for NoSQL Account
# Why: This is the actual database server. It takes about 5-10 minutes to deploy.
az cosmosdb create \
    --name $COSMOS_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --locations regionName=$LOCATION failoverPriority=0 isZoneRedundant=False \
    --default-consistency-level Session

# 5. Create Database
# Why: Inside the account, we need a specific database to hold our containers.
az cosmosdb sql database create \
    --account-name $COSMOS_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --name $DATABASE_NAME

# 6. Create Container
# Why: The container holds the actual document chunks. 
# Gotcha: The partition key must match our query patterns. We partition by '/documentId' so all chunks for one document sit together on the same physical server.
az cosmosdb sql container create \
    --account-name $COSMOS_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --database-name $DATABASE_NAME \
    --name $CONTAINER_NAME \
    --partition-key-path "/documentId" \
    --throughput 400

# 7. Get Cosmos DB Endpoint
# Why: The Flask app needs to know where to connect.
COSMOS_ENDPOINT=$(az cosmosdb show \
    --name $COSMOS_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --query documentEndpoint \
    --output tsv)

echo "COSMOS_ENDPOINT=$COSMOS_ENDPOINT"

# 8. Assign Data Plane Role (RBAC)
# Why: By default, even the creator doesn't have data-plane access (to read/write data). We must grant ourselves the "Cosmos DB Built-in Data Contributor" role.
# Gotcha: Role assignment requires getting your current logged-in user's Object ID.
USER_ID=$(az ad signed-in-user show --query id --output tsv)

az cosmosdb sql role assignment create \
    --account-name $COSMOS_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --scope "/" \
    --principal-id $USER_ID \
    --role-definition-id 00000000-0000-0000-0000-000000000002

# 9. Cleanup
# Why: Deletes everything to save costs once you are done.
# az group delete --name $RESOURCE_GROUP --yes --no-wait
