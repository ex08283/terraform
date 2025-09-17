terraform {
    backend "azurerm" {
    resource_group_name  = "terraform-state-rg" # Name of the resource group for the backend
    storage_account_name = "storageaccwe3434" # Name of the storage account for the backend
    container_name       = "tfstate" # Name of the container in the storage account
    key                  = "dev.terraform.tfstate" # Key for the state file in the container
    
  }
}