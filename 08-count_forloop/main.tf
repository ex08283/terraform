resource "azurerm_resource_group" "example" {
  lifecycle {
    create_before_destroy = false  
  }
  
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
  #count = length(var.storageaccount_name) # when using a list
  #name = var.storageaccount_name[count.index] 
  for_each = var.storageaccount_name # when using a set
  name = each.value #when using a set
  resource_group_name = azurerm_resource_group.example.name
  account_tier = "Standard"
  account_replication_type = "GRS"
  location = azurerm_resource_group.example.location

}
  