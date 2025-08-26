terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm" # Specify the provider for Azure
        version = "~> 3.0" # Specify the version of the Azure provider
    }

    azuread = {
      source  = "hashicorp/azuread" # Specify the provider for Azure Active Directory
      version = "~> 3.0" # Specify the version of the Azure AD provider
  }
    # Specify the required version of Terraform
  required_version = ">= 1.9.0" # Specify the required version of Terraform
}
}

provider "azurerm" {
  features {
      key_vault{
    purge_soft_delete_on_destroy = false
  }
  } # This block is required to enable the Azure provider features

}

provider "azuread" {
  
}

