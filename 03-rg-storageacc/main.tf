terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm" # Specify the provider for Azure
        version = "~> 3.0" # Specify the version of the Azure provider
    }
  }

  required_version = ">= 1.9.0" # Specify the required version of Terraform
}

provider "azurerm" {
  features {} # This block is required to enable the Azure provider features
  use_cli = true
  skip_provider_registration = true # Skip provider registration to avoid issues with Azure provider registration
}

resource "azurerm_resource_group" "rg_rm" {
    name     = "rg-terraform-acc" # Name of the resource group
    location = "West Europe" # Location where the resource group will be created
    tags = { # Tags for the resource group
        businesscriticality = "Low" # Tag to indicate the business criticality
        businessunit = "IT" # Tag to indicate the business unit
        costcentre = "tf" # Tag to indicate the cost center
        dataclassification = "Internal" # Tag to indicate the data classification
        workloadname = "tf" # Tag to indicate the workload name
    }
  
}

resource "azurerm_storage_account" "storageacc" {
    name                = "storageacc7089we3432" # This is the name of the storage account
    resource_group_name = azurerm_resource_group.rg_rm.name # The name of the resource group where the storage account will be created
    location            = azurerm_resource_group.rg_rm.location # The location of the storage account, same as the resource group
    account_tier        = "Standard" # The performance tier of the storage account      
    account_replication_type = "LRS" # The replication type of the storage account, LRS means Locally Redundant Storage

    tags = { # Tags for the storage account
        environment = "dev" # Tag to indicate the environment
    }
}