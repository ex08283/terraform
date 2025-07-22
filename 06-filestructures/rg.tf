resource "azurerm_resource_group" "rg_rm" {
    name     = "rg-terraform-stat" # Name of the resource group
    location = "UK South" # Location where the resource group will be created
    tags = { # Tags for the resource group
        businesscriticality = "Low" # Tag to indicate the business criticality
        businessunit = "IT" # Tag to indicate the business unit
        costcentre = "tf" # Tag to indicate the cost center
        dataclassification = "Internal" # Tag to indicate the data classification
        workloadname = "tf" # Tag to indicate the workload name
    }

    
  
}