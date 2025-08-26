#!/bin/bash

RESOURCE_GROUP_NAME=terraform-state-rg
STAGE_SA_ACCOUNT=tfstagebackend2025dj
DEV_SA_ACCOUNT=tfdevbackend2025dj
CONTAINER_NAME=tfstate

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location uksouth

# Create storage account for staging
az storage account create --name $STAGE_SA_ACCOUNT --resource-group $RESOURCE_GROUP_NAME --location uksouth --sku Standard_LRS --encryption-services blob

# Create storage account for dev environment
az storage account create --name $DEV_SA_ACCOUNT --resource-group $RESOURCE_GROUP_NAME --location uksouth --sku Standard_LRS --encryption-services blob

# Create blob container for staging environment
az storage container create --name $CONTAINER_NAME --account-name $STAGE_SA_ACCOUNT --auth-mode login

# Create blob container for dev environment
az storage container create --name $CONTAINER_NAME --account-name $DEV_SA_ACCOUNT --auth-mode login
