



resource "azurerm_storage_account" "storageacc" {
    name                = "storageaccwe3432" # This is the name of the storage account
    resource_group_name = azurerm_resource_group.rg_rm.name # The name of the resource group where the storage account will be created
    location            = azurerm_resource_group.rg_rm.location # The location of the storage account, same as the resource group
    account_tier        = "Standard" # The performance tier of the storage account      
    account_replication_type = "LRS" # The replication type of the storage account, LRS means Locally Redundant Storage

    tags = { # Tags for the storage account
        environment = local.common_tags.environment # Tag to indicate the environment, using the variable defined in locals.tf
    }

    #depends_on = [ azurerm_resource_group.rg_rm ] 
    # Ensure the storage account is created after the resource group, explicitly defining the dependency
    # implicit dependencies are automatically handled by Terraform, but it's good practice to define them when necessary.
    # avoid explicit dependencies unless necessary, as Terraform manages dependencies automatically.
}


