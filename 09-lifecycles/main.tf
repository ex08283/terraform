resource "azurerm_resource_group" "example" {

# With create_before_destroy = true in the lifecycle block of the resource group, if you make a change that requires replacing the resource group (like changing its name or location),
# Terraform will first create the new resource group, move dependent resources (like storage accounts) to it, and only then destroy the old group. This prevents downtime and accidental deletion of dependent resources.


  name     = "${var.environment}-resources"
  location = var.allowed_locations[0] # Use the first allowed location from the list
  tags = {
    businesscriticality = var.resource_tags.businesscriticality
    businessunit        = var.resource_tags.businessunit
    costcentre         = var.resource_tags.costcentre
    dataclassification = var.resource_tags.dataclassification
    workloadname       = var.resource_tags.workloadname
  }
}

# Example of using for loop or count
resource "azurerm_storage_account" "example" {
  
  # The lifecycle block with ignore_changes ensures that changes to the 'tags' attribute will be ignored by Terraform,
  # so updates to tags outside of Terraform (e.g., in the Azure Portal) won't trigger a resource recreation or update.
  lifecycle {
    ignore_changes = [ tags  ] 
    prevent_destroy = true # This prevents the resource from being destroyed by Terraform.

    # error will be thown
#      Error: Instance cannot be destroyed
# │
# │   on main.tf line 19:
# │   19: resource "azurerm_storage_account" "example" {
# │
# │ Resource azurerm_storage_account.example["djtutorial71"] has lifecycle.prevent_destroy set, but the plan calls for this 
# │ resource to be destroyed. To avoid this error and continue with the plan, either disable lifecycle.prevent_destroy or   
# │ reduce the scope of the plan using the -target option.

    # way that causes it to be replaced, then all azurerm_storage_account.example resources will also be replaced 
    replace_triggered_by = [ azurerm_resource_group.example ]

    precondition {
      condition = contains(var.allowed_locations,var.location)
      error_message = "Location is not contained in array or locations"
    }
  }



  #count = length(var.storageaccount_name) # when using a list
  #name = var.storageaccount_name[count.index] 
  for_each = var.storageaccount_name # when using a set
  name = each.value #when using a set
  resource_group_name = azurerm_resource_group.example.name
  account_tier = "Standard"
  account_replication_type = "GRS"
  location = var.location
  tags = {
    test = "test4"}

}
  